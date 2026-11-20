-- Run this in the Supabase SQL Editor to add support for toggling whether
-- an invoice is counted in the Layout (Order Summary) screen for its date.

alter table public.invoices
  add column if not exists include_in_layout boolean not null default true;
