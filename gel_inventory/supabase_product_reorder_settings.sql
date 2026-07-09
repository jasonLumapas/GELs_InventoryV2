-- Run this in the Supabase SQL Editor to add per-product reorder settings
-- used by the Reorder Suggestions report.

alter table public.products
  add column if not exists reorder_point integer,
  add column if not exists reorder_quantity integer;
