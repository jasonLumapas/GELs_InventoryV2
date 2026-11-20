-- Run this in the Supabase SQL Editor to add support for storing a client's
-- contact / telephone number.

alter table public.clients
  add column if not exists contact text;
