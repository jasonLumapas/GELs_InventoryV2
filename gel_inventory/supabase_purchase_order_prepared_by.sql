-- Run this in the Supabase SQL Editor to add the "Prepared by" field to
-- purchase orders.

alter table public.purchase_orders
  add column if not exists prepared_by text;
