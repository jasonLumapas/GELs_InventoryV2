-- Run this in the Supabase SQL Editor to add support for the
-- "Purchase Order" feature.

create table if not exists public.purchase_orders (
  id text primary key,
  supplier_id text not null references public.suppliers(id),
  order_date timestamptz not null default now(),
  reference_number text,
  total_amount numeric not null default 0,
  status text not null default 'open',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.purchase_order_items (
  id text primary key,
  purchase_order_id text not null references public.purchase_orders(id),
  product_id text not null references public.products(id),
  price numeric not null,
  cases numeric not null,
  amount numeric not null
);

-- Helpful indexes
create index if not exists idx_po_supplier_id on public.purchase_orders(supplier_id);
create index if not exists idx_po_order_date on public.purchase_orders(order_date);
create index if not exists idx_poi_purchase_order_id on public.purchase_order_items(purchase_order_id);
create index if not exists idx_poi_product_id on public.purchase_order_items(product_id);

-- RLS left disabled, matching the existing tables (the app connects with the
-- anon key only and has no sign-in flow, so an `authenticated`-only policy
-- would block all access to these tables).
