-- Run this in the Supabase SQL Editor to add support for the deleted
-- invoice items audit log (shown as "Deleted Items" in the Invoice Detail
-- screen).

create table if not exists public.deleted_invoice_items (
  id text primary key,
  invoice_id text references public.invoices(id),
  product_id text references public.products(id),
  -- unit_type: 'box' | 'piece'
  unit_type text not null,
  quantity integer not null,
  price_per_piece double precision not null,
  subtotal double precision not null,
  is_free boolean not null default false,
  deleted_at timestamptz not null default now()
);

create index if not exists idx_deleted_invoice_items_invoice_id
  on public.deleted_invoice_items(invoice_id);

-- RLS left disabled, matching the existing tables (the app connects with the
-- anon key only and has no sign-in flow, so an `authenticated`-only policy
-- would block all access to these tables).
