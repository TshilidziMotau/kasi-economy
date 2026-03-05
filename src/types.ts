export type Role = 'CUSTOMER' | 'COURIER' | 'STORE_OWNER' | 'ADMIN';

export type OrderStatus =
  | 'PLACED'
  | 'COURIER_ASSIGNED'
  | 'STORE_ACCEPTED'
  | 'PAID_AT_STORE'
  | 'PICKED_UP'
  | 'ON_ROUTE'
  | 'DELIVERED';

export interface Store {
  id: string;
  name: string;
  address: string;
  lat: number;
  lng: number;
}

export interface Product {
  id: string;
  storeId: string;
  name: string;
  price: number;
}
