-- Run this in the Supabase SQL Editor to add support for a supplier-quoted
-- price (distinct from the system/withdrawal price) and a "free" flag on
-- purchase order items, matching supplier deliveries.

alter table public.purchase_order_items
  add column if not exists system_price numeric not null default 0,
  add column if not exists is_free boolean not null default false;
