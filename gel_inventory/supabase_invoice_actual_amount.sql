-- Run this in the Supabase SQL Editor to add support for the optional
-- "actual amount" of the referenced receipt on an invoice.

alter table public.invoices
  add column if not exists actual_amount numeric;
