-- Run this in the Supabase SQL Editor to add support for remembering the
-- discounts/VAT applied on a supplier delivery, so they can be replayed
-- correctly when the delivery is reopened for editing.

alter table public.supplier_received_invoices
  add column if not exists discount_percents text,
  add column if not exists vat_enabled boolean not null default false;

alter table public.supplier_received_invoice_items
  add column if not exists raw_supplier_price numeric;
