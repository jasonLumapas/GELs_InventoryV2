-- Run this in the Supabase SQL Editor to add support for the
-- "Supplier Pricing" tab on the Edit Product page.

create table if not exists public.product_supplier_prices (
  id text primary key,
  product_id text not null references public.products(id),
  price_box numeric not null,
  discount_percents text,
  vat_enabled boolean not null default false
);

alter table public.product_supplier_prices
  add column if not exists discount_percents text,
  add column if not exists vat_enabled boolean not null default false;

create index if not exists idx_product_supplier_prices_product_id
  on public.product_supplier_prices(product_id);

-- RLS left disabled, matching the existing tables (the app connects with the
-- anon key only and has no sign-in flow, so an `authenticated`-only policy
-- would block all access to these tables).
