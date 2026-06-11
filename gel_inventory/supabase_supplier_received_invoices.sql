-- Run this in the Supabase SQL Editor to add support for the
-- "Delivery from Supplier" (Supplier Received Invoice) feature.

create table if not exists public.supplier_received_invoices (
  id text primary key,
  supplier_id text not null references public.suppliers(id),
  received_date timestamptz not null default now(),
  reference_number text,
  total_amount_system numeric not null default 0,
  total_amount_supplier numeric not null default 0,
  status text not null default 'received',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.supplier_received_invoice_items (
  id text primary key,
  received_invoice_id text not null references public.supplier_received_invoices(id),
  product_id text not null references public.products(id),
  unit_type text not null,
  quantity integer not null,
  system_price numeric not null,
  supplier_price numeric not null,
  subtotal_system numeric not null,
  subtotal_supplier numeric not null
);

-- Helpful indexes
create index if not exists idx_sri_supplier_id on public.supplier_received_invoices(supplier_id);
create index if not exists idx_sri_received_date on public.supplier_received_invoices(received_date);
create index if not exists idx_srii_received_invoice_id on public.supplier_received_invoice_items(received_invoice_id);
create index if not exists idx_srii_product_id on public.supplier_received_invoice_items(product_id);

-- RLS left disabled, matching the existing tables (the app connects with the
-- anon key only and has no sign-in flow, so an `authenticated`-only policy
-- would block all access to these tables).
