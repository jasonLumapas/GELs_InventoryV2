-- Add a creation timestamp to Off-site Loading / Stocks Return transactions.
-- Existing records use their transaction date as the best available fallback.

alter table public.van_stocks
  add column if not exists created_at timestamptz;

update public.van_stocks
set created_at = date
where created_at is null;

alter table public.van_stocks
  alter column created_at set default now(),
  alter column created_at set not null;
