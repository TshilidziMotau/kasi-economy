insert into public.stores (id, name, address, lat, lng) values
  ('11111111-1111-1111-1111-111111111111', 'Mandla Mini Market', '12 Vilakazi St, Soweto', -26.2481, 27.9077),
  ('22222222-2222-2222-2222-222222222222', 'Zola Fresh', '87 Mofolo Ave, Soweto', -26.2514, 27.8994),
  ('33333333-3333-3333-3333-333333333333', 'Ekasi Saver', '4 Chris Hani Rd, Soweto', -26.2433, 27.9132)
on conflict do nothing;

insert into public.products (store_id, name, price, active) values
  ('11111111-1111-1111-1111-111111111111', 'White Bread', 16, true),
  ('11111111-1111-1111-1111-111111111111', 'Long Life Milk 1L', 20, true),
  ('11111111-1111-1111-1111-111111111111', 'Eggs 6 pack', 24, true),
  ('11111111-1111-1111-1111-111111111111', 'Maize Meal 2.5kg', 34, true),
  ('11111111-1111-1111-1111-111111111111', 'Tomato Sauce', 18, true),
  ('11111111-1111-1111-1111-111111111111', 'Sugar 1kg', 25, true),
  ('11111111-1111-1111-1111-111111111111', 'Tea 52 bags', 26, true),
  ('11111111-1111-1111-1111-111111111111', 'Soap Bar', 12, true),
  ('22222222-2222-2222-2222-222222222222', 'Rice 2kg', 38, true),
  ('22222222-2222-2222-2222-222222222222', 'Cooking Oil 750ml', 29, true),
  ('22222222-2222-2222-2222-222222222222', 'Apples 1kg', 22, true),
  ('22222222-2222-2222-2222-222222222222', 'Bananas 1kg', 20, true),
  ('22222222-2222-2222-2222-222222222222', 'Potatoes 2kg', 30, true),
  ('22222222-2222-2222-2222-222222222222', 'Onions 1kg', 17, true),
  ('22222222-2222-2222-2222-222222222222', 'Toilet Paper 9 pack', 54, true),
  ('22222222-2222-2222-2222-222222222222', 'Salt 1kg', 12, true),
  ('33333333-3333-3333-3333-333333333333', 'Brown Sugar 1kg', 25, true),
  ('33333333-3333-3333-3333-333333333333', 'Tea 100 bags', 31, true),
  ('33333333-3333-3333-3333-333333333333', 'Peanut Butter', 42, true),
  ('33333333-3333-3333-3333-333333333333', 'Noodles 5 pack', 27, true),
  ('33333333-3333-3333-3333-333333333333', 'Chutney', 19, true),
  ('33333333-3333-3333-3333-333333333333', 'Beans Tin', 16, true),
  ('33333333-3333-3333-3333-333333333333', 'Sardines Tin', 23, true),
  ('33333333-3333-3333-3333-333333333333', 'Dish Wash Liquid', 21, true);

-- demo auth users should be created in Supabase Auth UI first, then linked here
-- admin: admin@kasi.test
-- store owner: store@kasi.test
-- courier: courier@kasi.test
-- customer: customer@kasi.test
