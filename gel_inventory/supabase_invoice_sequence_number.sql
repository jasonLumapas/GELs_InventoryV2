-- Run this in the Supabase SQL Editor to add support for the persisted
-- sequential invoice display number.

alter table public.invoices
  add column if not exists sequence_number integer;

create unique index if not exists idx_invoices_sequence_number
  on public.invoices(sequence_number)
  where sequence_number is not null;
