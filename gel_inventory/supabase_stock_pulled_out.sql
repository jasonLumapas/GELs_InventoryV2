-- Run this in the Supabase SQL Editor to add support for the "Stock Pulled out"
-- bad-order type, which links to an invoice and automatically deducts the
-- pulled stock's sale value / cost from that invoice's totals.

alter table public.bad_orders
  add column if not exists invoice_id text;

alter table public.invoices
  add column if not exists stock_pulled_out_amount numeric,
  add column if not exists stock_pulled_out_cost numeric;
