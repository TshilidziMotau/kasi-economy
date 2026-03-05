create extension if not exists "uuid-ossp";

create type app_role as enum ('CUSTOMER', 'COURIER', 'STORE_OWNER', 'ADMIN');
create type courier_approval as enum ('PENDING', 'APPROVED', 'REJECTED');
create type order_status as enum ('PLACED', 'COURIER_ASSIGNED', 'STORE_ACCEPTED', 'PAID_AT_STORE', 'PICKED_UP', 'ON_ROUTE', 'DELIVERED');
create type ledger_status as enum ('SETTLED', 'UNSETTLED');

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id),
  role app_role not null,
  name text not null,
  phone text,
  store_id uuid,
  courier_approval_status courier_approval default 'PENDING'
);

create table if not exists public.stores (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  address text not null,
  lat numeric not null,
  lng numeric not null
);

alter table public.profiles
  add constraint fk_profiles_store
  foreign key (store_id) references public.stores(id);

create table if not exists public.products (
  id uuid primary key default uuid_generate_v4(),
  store_id uuid not null references public.stores(id),
  name text not null,
  price numeric(10,2) not null check (price > 0),
  active boolean default true
);

create table if not exists public.orders (
  id uuid primary key default uuid_generate_v4(),
  customer_id uuid not null references auth.users(id),
  store_id uuid not null references public.stores(id),
  courier_id uuid references auth.users(id),
  status order_status not null,
  items_subtotal numeric(10,2) not null,
  delivery_fee numeric(10,2) not null default 5,
  total numeric(10,2) not null,
  created_at timestamptz default now()
);

create table if not exists public.order_items (
  id uuid primary key default uuid_generate_v4(),
  order_id uuid not null references public.orders(id),
  product_id uuid not null references public.products(id),
  qty int not null check (qty > 0),
  unit_price numeric(10,2) not null check (unit_price > 0)
);

create table if not exists public.location_updates (
  id uuid primary key default uuid_generate_v4(),
  order_id uuid not null references public.orders(id),
  courier_id uuid not null references auth.users(id),
  lat numeric not null,
  lng numeric not null,
  created_at timestamptz default now()
);

create table if not exists public.commission_ledger (
  order_id uuid primary key references public.orders(id),
  store_id uuid not null references public.stores(id),
  commission_amount numeric(10,2) not null,
  ledger_status ledger_status not null default 'UNSETTLED',
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.stores enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.location_updates enable row level security;
alter table public.commission_ledger enable row level security;

create or replace function public.current_role() returns app_role
language sql stable security definer as $$
  select role from public.profiles where user_id = auth.uid();
$$;

create or replace function public.current_store_id() returns uuid
language sql stable security definer as $$
  select store_id from public.profiles where user_id = auth.uid();
$$;

create policy "read stores" on public.stores for select using (true);
create policy "read active products" on public.products for select using (active = true or public.current_role() in ('STORE_OWNER', 'ADMIN'));

create policy "orders customer read" on public.orders for select using (
  customer_id = auth.uid()
  or (courier_id = auth.uid())
  or (public.current_role() = 'STORE_OWNER' and store_id = public.current_store_id())
  or public.current_role() = 'ADMIN'
);

create policy "orders store owner update" on public.orders for update using (
  public.current_role() = 'STORE_OWNER' and store_id = public.current_store_id()
);

create policy "orders courier update" on public.orders for update using (
  courier_id = auth.uid() or public.current_role() = 'ADMIN'
);

create policy "order items read" on public.order_items for select using (
  exists (
    select 1 from public.orders o
    where o.id = order_id
    and (
      o.customer_id = auth.uid()
      or o.courier_id = auth.uid()
      or (public.current_role() = 'STORE_OWNER' and o.store_id = public.current_store_id())
      or public.current_role() = 'ADMIN'
    )
  )
);

create policy "location read" on public.location_updates for select using (
  exists (
    select 1 from public.orders o
    where o.id = order_id
      and (
        (o.customer_id = auth.uid() and o.status = 'ON_ROUTE')
        or o.courier_id = auth.uid()
        or (public.current_role() = 'STORE_OWNER' and o.store_id = public.current_store_id())
        or public.current_role() = 'ADMIN'
      )
  )
);

create policy "location insert by assigned courier on route" on public.location_updates for insert with check (
  exists (
    select 1 from public.orders o
    where o.id = order_id
      and o.courier_id = auth.uid()
      and o.status = 'ON_ROUTE'
  )
);

create policy "ledger admin only" on public.commission_ledger for all using (public.current_role() = 'ADMIN') with check (public.current_role() = 'ADMIN');

create or replace function public.create_order(p_store_id uuid, p_items jsonb)
returns uuid language plpgsql security definer as $$
declare
  v_order_id uuid;
  v_subtotal numeric(10,2) := 0;
  v_item jsonb;
  v_product_id uuid;
  v_qty int;
  v_price numeric(10,2);
begin
  if public.current_role() <> 'CUSTOMER' then
    raise exception 'forbidden';
  end if;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_qty := (v_item->>'qty')::int;

    if v_qty <= 0 then
      raise exception 'invalid quantity';
    end if;

    select price into v_price from public.products where id = v_product_id and store_id = p_store_id and active = true;
    if v_price is null then
      raise exception 'product unavailable';
    end if;

    v_subtotal := v_subtotal + (v_price * v_qty);
  end loop;

  if v_subtotal = 0 then
    raise exception 'empty order';
  end if;

  insert into public.orders(customer_id, store_id, status, items_subtotal, delivery_fee, total)
  values (auth.uid(), p_store_id, 'PLACED', v_subtotal, 5, v_subtotal + 5)
  returning id into v_order_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_qty := (v_item->>'qty')::int;
    select price into v_price from public.products where id = v_product_id;

    insert into public.order_items(order_id, product_id, qty, unit_price)
    values (v_order_id, v_product_id, v_qty, v_price);
  end loop;

  insert into public.commission_ledger(order_id, store_id, commission_amount)
  values (v_order_id, p_store_id, round(v_subtotal * 0.10, 2));

  return v_order_id;
end;
$$;

create or replace function public.courier_accept_order(p_order_id uuid)
returns void language plpgsql security definer as $$
begin
  if public.current_role() <> 'COURIER' then raise exception 'forbidden'; end if;
  if (select courier_approval_status from public.profiles where user_id = auth.uid()) <> 'APPROVED' then raise exception 'not approved'; end if;

  update public.orders
  set courier_id = auth.uid(), status = 'COURIER_ASSIGNED'
  where id = p_order_id and status = 'PLACED' and courier_id is null;

  if not found then raise exception 'invalid transition'; end if;
end;
$$;

create or replace function public.store_accept_order(p_order_id uuid)
returns void language plpgsql security definer as $$
begin
  if public.current_role() <> 'STORE_OWNER' then raise exception 'forbidden'; end if;

  update public.orders
  set status = 'STORE_ACCEPTED'
  where id = p_order_id
    and status = 'COURIER_ASSIGNED'
    and store_id = public.current_store_id();

  if not found then raise exception 'invalid transition'; end if;
end;
$$;

create or replace function public.store_confirm_payment(p_order_id uuid)
returns void language plpgsql security definer as $$
begin
  if public.current_role() <> 'STORE_OWNER' then raise exception 'forbidden'; end if;

  update public.orders
  set status = 'PAID_AT_STORE'
  where id = p_order_id
    and status = 'STORE_ACCEPTED'
    and store_id = public.current_store_id();

  if not found then raise exception 'invalid transition'; end if;
end;
$$;

create or replace function public.courier_set_picked_up(p_order_id uuid)
returns void language plpgsql security definer as $$
begin
  if public.current_role() <> 'COURIER' then raise exception 'forbidden'; end if;

  update public.orders set status = 'PICKED_UP'
  where id = p_order_id and status = 'PAID_AT_STORE' and courier_id = auth.uid();

  if not found then raise exception 'invalid transition'; end if;
end;
$$;

create or replace function public.courier_set_on_route(p_order_id uuid)
returns void language plpgsql security definer as $$
begin
  if public.current_role() <> 'COURIER' then raise exception 'forbidden'; end if;

  update public.orders set status = 'ON_ROUTE'
  where id = p_order_id and status = 'PICKED_UP' and courier_id = auth.uid();

  if not found then raise exception 'invalid transition'; end if;
end;
$$;

create or replace function public.courier_set_delivered(p_order_id uuid)
returns void language plpgsql security definer as $$
begin
  if public.current_role() <> 'COURIER' then raise exception 'forbidden'; end if;

  update public.orders set status = 'DELIVERED'
  where id = p_order_id and status = 'ON_ROUTE' and courier_id = auth.uid();

  if not found then raise exception 'invalid transition'; end if;
end;
$$;

create or replace view public.customer_order_view as
select o.id, o.customer_id, o.store_id, o.status, o.items_subtotal, o.delivery_fee, o.total, o.created_at
from public.orders o;
