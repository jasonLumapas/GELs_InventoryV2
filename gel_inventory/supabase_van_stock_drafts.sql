-- Run this in the Supabase SQL Editor to add support for auto-saved
-- "Loading" / "Stocks Return" drafts in the Off-site Loading screen.

create table if not exists public.van_stock_drafts (
  id text primary key,
  -- type: 'out' (Loading) | 'in' (Stocks Return)
  type text not null,
  area_id text references public.van_areas(id),
  tx_date timestamptz not null default now(),
  -- JSON-encoded list of {product_id, unit_type, quantity}
  items_json text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_van_stock_drafts_type on public.van_stock_drafts(type);

-- RLS left disabled, matching the existing tables (the app connects with the
-- anon key only and has no sign-in flow, so an `authenticated`-only policy
-- would block all access to these tables).
