import { useMemo, useState } from 'react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { products, stores } from './mock-data';
import { OrderStatus, Role } from './types';

const DELIVERY_FEE = 5;
const statusFlow: OrderStatus[] = ['PLACED', 'COURIER_ASSIGNED', 'STORE_ACCEPTED', 'PAID_AT_STORE', 'PICKED_UP', 'ON_ROUTE', 'DELIVERED'];

export default function App() {
  const [role, setRole] = useState<Role>('CUSTOMER');
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col gap-4 p-4">
      <header className="rounded-2xl bg-slate-900 p-4 text-white">
        <p className="text-xs">App Name</p>
        <h1 className="text-2xl font-bold">KASI ECONOMY</h1>
      </header>
      <Card className="space-y-2">
        <p className="text-xs font-semibold text-slate-500">Role</p>
        <div className="grid grid-cols-2 gap-2">
          {(['CUSTOMER', 'COURIER', 'STORE_OWNER', 'ADMIN'] as Role[]).map((nextRole) => (
            <Button
              key={nextRole}
              className={role === nextRole ? '' : 'bg-slate-200 text-slate-800 hover:bg-slate-300'}
              onClick={() => setRole(nextRole)}
            >
              {nextRole}
            </Button>
          ))}
        </div>
      </Card>
      {role === 'CUSTOMER' && <CustomerScreen />}
      {role === 'COURIER' && <CourierScreen />}
      {role === 'STORE_OWNER' && <StoreOwnerScreen />}
      {role === 'ADMIN' && <AdminScreen />}
      <Card>
        <h2 className="text-sm font-semibold">Status flow</h2>
        <p className="mt-2 text-xs text-slate-600">{statusFlow.join(' → ')}</p>
      </Card>
    </main>
  );
}

function CustomerScreen() {
  const [activeStoreId, setActiveStoreId] = useState(stores[0].id);
  const [cart, setCart] = useState<Record<string, number>>({});
  const activeProducts = products.filter((product) => product.storeId === activeStoreId);
  const subtotal = useMemo(
    () =>
      Object.entries(cart).reduce((total, [productId, qty]) => {
        const product = products.find((item) => item.id === productId);
        return total + (product?.price ?? 0) * qty;
      }, 0),
    [cart]
  );

  return (
    <>
      <Card className="space-y-3">
        <h2 className="text-lg font-bold">Nearby stores</h2>
        <p className="text-sm text-slate-600">Map unavailable, showing list fallback.</p>
        {stores.map((store) => (
          <button
            key={store.id}
            onClick={() => setActiveStoreId(store.id)}
            className="w-full rounded-xl border border-slate-200 p-3 text-left"
          >
            <p className="font-semibold">{store.name}</p>
            <p className="text-xs text-slate-500">{store.address}</p>
            <p className="mt-2 text-sm text-green-700">Open store</p>
          </button>
        ))}
      </Card>

      <Card className="space-y-3">
        <h2 className="text-lg font-bold">{stores.find((store) => store.id === activeStoreId)?.name}</h2>
        {activeProducts.map((product) => (
          <div key={product.id} className="flex items-center justify-between rounded-lg border border-slate-100 p-2">
            <div>
              <p className="font-medium">{product.name}</p>
              <p className="text-sm">R{product.price.toFixed(2)}</p>
            </div>
            <Button
              onClick={() => {
                setCart((prev) => ({ ...prev, [product.id]: (prev[product.id] ?? 0) + 1 }));
              }}
              className="h-9"
            >
              Add
            </Button>
          </div>
        ))}
        <p className="text-xs text-green-700">Added to cart</p>
      </Card>

      <Card className="space-y-2">
        <h2 className="text-lg font-bold">Checkout</h2>
        <p className="flex justify-between text-sm"><span>Subtotal</span><span>R{subtotal.toFixed(2)}</span></p>
        <p className="flex justify-between text-sm"><span>Delivery fee</span><span>R{DELIVERY_FEE.toFixed(2)}</span></p>
        <p className="flex justify-between text-base font-bold"><span>Total</span><span>R{(subtotal + DELIVERY_FEE).toFixed(2)}</span></p>
        <Button className="mt-2 w-full">Place order</Button>
      </Card>

      <Card>
        <h2 className="font-semibold">Tracking</h2>
        <p className="mt-2 text-sm">On the way — arriving soon</p>
      </Card>
    </>
  );
}

function CourierScreen() {
  return (
    <Card className="space-y-3">
      <h2 className="text-lg font-bold">Courier dashboard</h2>
      <p className="text-sm">Approval status: PENDING</p>
      <p className="text-sm">Jobs appear after approval and within 1km.</p>
      <Button>Accept job</Button>
    </Card>
  );
}

function StoreOwnerScreen() {
  return (
    <Card className="space-y-3">
      <h2 className="text-lg font-bold">Store orders</h2>
      <p className="text-sm">Order placed</p>
      <p className="text-sm">Courier accepted</p>
      <Button>Accept order</Button>
      <Button>Payment confirmed by store</Button>
    </Card>
  );
}

function AdminScreen() {
  return (
    <Card className="space-y-3">
      <h2 className="text-lg font-bold">Admin panel</h2>
      <p className="text-sm">Store & product CRUD</p>
      <p className="text-sm">Courier approvals</p>
      <p className="text-sm">Internal ledger status controls</p>
    </Card>
  );
}
