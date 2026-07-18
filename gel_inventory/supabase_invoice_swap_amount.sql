-- Run this in the Supabase SQL Editor to add support for the optional
-- "swap amount" deducted from an invoice's total for swapped items.

alter table public.invoices
  add column if not exists swap_amount numeric;
