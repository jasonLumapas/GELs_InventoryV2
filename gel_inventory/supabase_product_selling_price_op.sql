-- Run this in the Supabase SQL Editor to add the "Selling Price/pc (OP)"
-- column used by the product form's Pricing section.

alter table public.product_prices
  add column if not exists selling_price_op numeric;
