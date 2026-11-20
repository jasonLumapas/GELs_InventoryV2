-- Run this in the Supabase SQL Editor to add support for remembering the
-- discounts/VAT applied on a purchase order, so they can be replayed
-- correctly when the order is reopened for editing.

alter table public.purchase_orders
  add column if not exists discount_percents text,
  add column if not exists vat_enabled boolean not null default false;

alter table public.purchase_order_items
  add column if not exists raw_price numeric;
