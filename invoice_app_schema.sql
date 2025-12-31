-- =====================================================
-- InvoiceApp - Database Schema
-- Fresh Environment Setup
-- =====================================================

-- Required extension
create extension if not exists "uuid-ossp";

-- =====================================================
-- PROFILES TABLE
-- =====================================================
create table if not exists public.profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique references auth.users(id) on delete cascade,

  business_name text,
  address text,
  proprietor text,
  phone_numbers text,

  logo_url text,
  signature_url text,

  custom_logo_1_url text,
  custom_logo_2_url text,
  custom_logo_3_url text,
  custom_logo_4_url text,

  custom_field_label text,
  custom_field_placeholder text,

  gstin text,

  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Profiles Policies
create policy "Profiles: select own"
on public.profiles
for select
using (auth.uid() = user_id);

create policy "Profiles: insert own"
on public.profiles
for insert
with check (auth.uid() = user_id);

create policy "Profiles: update own"
on public.profiles
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- =====================================================
-- INVOICES TABLE
-- =====================================================
create table if not exists public.invoices (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,

  customer_name text not null,
  customer_phone text,
  vehicle_number text,

  invoice_date date not null default current_date,
  invoice_number text not null,

  subtotal numeric not null default 0,
  discount_total numeric not null default 0,
  is_discount_total_percentage boolean not null default false,

  gst_percentage numeric not null default 0,
  total_amount numeric not null default 0,

  created_at timestamptz default now()
);

alter table public.invoices enable row level security;

-- Invoices Policies
create policy "Invoices: select own"
on public.invoices
for select
using (auth.uid() = user_id);

create policy "Invoices: insert own"
on public.invoices
for insert
with check (auth.uid() = user_id);

create policy "Invoices: update own"
on public.invoices
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Invoices: delete own"
on public.invoices
for delete
using (auth.uid() = user_id);

-- =====================================================
-- INVOICE ITEMS TABLE
-- =====================================================
create table if not exists public.invoice_items (
  id uuid primary key default uuid_generate_v4(),
  invoice_id uuid not null references public.invoices(id) on delete cascade,

  item_name text not null,
  quantity numeric not null default 1,
  price numeric not null default 0,

  discount_item numeric not null default 0,
  is_discount_item_percentage boolean not null default false,

  amount numeric not null default 0,

  created_at timestamptz default now()
);

alter table public.invoice_items enable row level security;

-- Invoice Items Policies
create policy "InvoiceItems: select own"
on public.invoice_items
for select
using (
  exists (
    select 1
    from public.invoices
    where invoices.id = invoice_items.invoice_id
      and invoices.user_id = auth.uid()
  )
);

create policy "InvoiceItems: insert own"
on public.invoice_items
for insert
with check (
  exists (
    select 1
    from public.invoices
    where invoices.id = invoice_items.invoice_id
      and invoices.user_id = auth.uid()
  )
);

create policy "InvoiceItems: update own"
on public.invoice_items
for update
using (
  exists (
    select 1
    from public.invoices
    where invoices.id = invoice_items.invoice_id
      and invoices.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.invoices
    where invoices.id = invoice_items.invoice_id
      and invoices.user_id = auth.uid()
  )
);

create policy "InvoiceItems: delete own"
on public.invoice_items
for delete
using (
  exists (
    select 1
    from public.invoices
    where invoices.id = invoice_items.invoice_id
      and invoices.user_id = auth.uid()
  )
);

-- =====================================================
-- STORAGE (ASSETS BUCKET)
-- =====================================================

-- Create assets bucket (public read)
insert into storage.buckets (id, name, public)
values ('assets', 'assets', true)
on conflict (id) do nothing;

-- Remove existing policies if rerun
drop policy if exists "Assets Public Read" on storage.objects;
drop policy if exists "Assets Upload Own" on storage.objects;
drop policy if exists "Assets Update Own" on storage.objects;
drop policy if exists "Assets Delete Own" on storage.objects;

-- Public read access (logos, signatures)
create policy "Assets Public Read"
on storage.objects
for select
using (bucket_id = 'assets');

-- Upload to own folder
create policy "Assets Upload Own"
on storage.objects
for insert
with check (
  bucket_id = 'assets'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- Update own files
create policy "Assets Update Own"
on storage.objects
for update
using (
  bucket_id = 'assets'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- Delete own files
create policy "Assets Delete Own"
on storage.objects
for delete
using (
  bucket_id = 'assets'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- END OF FILE
-- =====================================================
