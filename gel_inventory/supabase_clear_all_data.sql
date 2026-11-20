-- WARNING: this permanently deletes ALL data from every table in the
-- database (full reset). Table structures, indexes, and RLS settings are
-- left intact. Run this in the Supabase SQL Editor only if you are sure.

truncate table
  public.invoice_payments,
  public.invoice_items,
  public.invoices,
  public.bad_order_items,
  public.bad_orders,
  public.van_stocks,
  public.van_areas,
  public.stock_movements,
  public.supplier_received_invoice_items,
  public.supplier_received_invoices,
  public.purchase_order_items,
  public.purchase_orders,
  public.inventory,
  public.product_discounts,
  public.product_prices,
  public.products,
  public.clients,
  public.suppliers
cascade;
