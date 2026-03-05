import { Product, Store } from './types';

export const stores: Store[] = [
  { id: 's1', name: 'Mandla Mini Market', address: '12 Vilakazi St, Soweto', lat: -26.2481, lng: 27.9077 },
  { id: 's2', name: 'Zola Fresh', address: '87 Mofolo Ave, Soweto', lat: -26.2514, lng: 27.8994 },
  { id: 's3', name: 'Ekasi Saver', address: '4 Chris Hani Rd, Soweto', lat: -26.2433, lng: 27.9132 }
];

export const products: Product[] = [
  { id: 'p1', storeId: 's1', name: 'White Bread', price: 16 },
  { id: 'p2', storeId: 's1', name: 'Long Life Milk 1L', price: 20 },
  { id: 'p3', storeId: 's1', name: 'Eggs 6 pack', price: 24 },
  { id: 'p4', storeId: 's2', name: 'Apples 1kg', price: 22 },
  { id: 'p5', storeId: 's2', name: 'Rice 2kg', price: 38 },
  { id: 'p6', storeId: 's2', name: 'Cooking Oil 750ml', price: 29 },
  { id: 'p7', storeId: 's3', name: 'Brown Sugar 1kg', price: 25 },
  { id: 'p8', storeId: 's3', name: 'Tea 100 bags', price: 31 },
  { id: 'p9', storeId: 's3', name: 'Soap Bar', price: 12 }
];
