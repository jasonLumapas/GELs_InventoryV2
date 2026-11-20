-- Run this in the Supabase SQL Editor to add support for recording the
-- date a customer's check was issued, alongside the existing check amount,
-- due date, and reference number fields on invoices.

alter table public.invoices
  add column if not exists check_issued_date timestamptz;
