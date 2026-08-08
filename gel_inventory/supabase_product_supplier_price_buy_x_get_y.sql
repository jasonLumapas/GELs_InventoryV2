-- Run this in the Supabase SQL Editor to add support for a "Buy X Get Y
-- Free" term from the supplier on the "Supplier Pricing" tab of the Edit
-- Product page. Applied automatically in New Supplier Delivery once the
-- ordered quantity crosses the threshold.

alter table public.product_supplier_prices
  add column if not exists buy_min_quantity_pieces integer,
  add column if not exists free_quantity_pieces integer,
  add column if not exists free_quantity_unit text not null default 'box';
