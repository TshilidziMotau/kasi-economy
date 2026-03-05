# KASI ECONOMY

Mobile-first spaza delivery web app scaffold using Vite + React + TypeScript, Tailwind CSS, and Supabase SQL migrations.

## What is included

- Role-focused UI shells for CUSTOMER, COURIER, STORE_OWNER, and ADMIN
- Customer map/list fallback + store bottom-sheet style panel
- Checkout totals limited to subtotal, delivery fee (R5), and total
- Ordered delivery status flow display
- Supabase migration with:
  - Core tables
  - RLS policies per role
  - Strict status transition RPC functions
  - Internal admin ledger table
- Seed SQL for demo stores and products

## Local run

```bash
npm install
npm run dev
```

## Supabase

Apply SQL files in:

- `supabase/migrations/202603052200_init.sql`
- `supabase/seed/seed.sql`
