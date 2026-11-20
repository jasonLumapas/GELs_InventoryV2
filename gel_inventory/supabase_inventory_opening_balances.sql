-- Run this in the Supabase SQL Editor before deploying the app version that
-- persists the Inventory Report's daily beginning quantities.

create table if not exists public.inventory_opening_balances (
  id text primary key,
  product_id text not null references public.products(id),
  report_date date not null,
  quantity_pieces integer not null,
  created_at timestamptz not null default now(),
  unique (product_id, report_date)
);

create index if not exists idx_inventory_opening_balances_report_date
  on public.inventory_opening_balances(report_date);

-- RLS left disabled, matching the existing tables (the app connects with the
-- anon key only and has no sign-in flow, so an authenticated-only policy
-- would block all access to this table).
