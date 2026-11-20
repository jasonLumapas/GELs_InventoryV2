-- Run this in the Supabase SQL Editor to add support for auto-saved
-- "New Bad Order / Return" drafts in the Bad Orders & Returns screen.

create table if not exists public.bad_order_drafts (
  id text primary key,
  -- type: 'bad_order' | 'return'
  type text not null,
  client_id text references public.clients(id),
  no_client boolean not null default false,
  date timestamptz not null default now(),
  notes text,
  -- JSON-encoded list of {product_id, boxes, pieces}
  items_json text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_bad_order_drafts_type on public.bad_order_drafts(type);

-- RLS left disabled, matching the existing tables (the app connects with the
-- anon key only and has no sign-in flow, so an `authenticated`-only policy
-- would block all access to these tables).
