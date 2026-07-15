-- ============================================================
-- Miyhav · Migration 0003 — pets (özel; yalnızca sahibe)
-- Amaç: Kullanıcının kendi petleri. Deny-by-default RLS: sahibi okur/yazar; başka
--   kullanıcı erişemez. owner_id insert'te auth.uid()'e eşit olmalı ve GÜNCELLEMEDE
--   değiştirilemez (BEFORE UPDATE trigger). Sosyal/sağlık/foto upload BU GÖREVDE YOK.
-- Not: Mevcut migration'lar RETROAKTİF DEĞİŞTİRİLMEZ; bu ayrı, sıralı migration'dır.
-- ============================================================

create extension if not exists pgcrypto;

-- ---------- pets tablosu ----------
create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  -- Tür kümesi oynak olabildiğinden text + check (DECISIONS D-004).
  species text not null,
  breed text,
  sex text,
  birth_date date,
  is_birth_date_estimated boolean not null default false,
  color text,
  current_weight numeric(5, 2),
  profile_photo_path text,
  short_description text,
  microchip_number text,
  is_neutered boolean,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint pets_name_len check (char_length(btrim(name)) between 1 and 40),
  constraint pets_species_valid check (
    species in ('cat', 'dog', 'bird', 'rabbit', 'fish', 'reptile', 'other')
  ),
  constraint pets_sex_valid check (
    sex is null or sex in ('male', 'female', 'unknown')
  ),
  constraint pets_breed_len check (breed is null or char_length(breed) <= 40),
  constraint pets_color_len check (color is null or char_length(color) <= 30),
  constraint pets_desc_len check (
    short_description is null or char_length(short_description) <= 200
  ),
  constraint pets_microchip_len check (
    microchip_number is null or char_length(microchip_number) <= 30
  ),
  constraint pets_weight_range check (
    current_weight is null
    or (current_weight > 0 and current_weight <= 200)
  )
);

comment on table public.pets is
  'Petin ÖZEL verisi; yalnızca sahibe (owner_id). Sosyal görünüm ayrı güvenli '
  'projeksiyondan gelir; mikroçip/özel alanlar projeksiyona konmaz.';

create index if not exists pets_owner_id_idx on public.pets (owner_id);

-- ============================================================
-- Trigger: updated_at bakımı + değişmez alanlar (owner_id / id / created_at).
-- Normal update'te bu alanlar eski değerine sabitlenir → başka kullanıcıya
-- devredilemez, id/oluşturma zamanı değişmez.
-- ============================================================
create or replace function public.pets_before_update()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.id := old.id;
  new.owner_id := old.owner_id;
  new.created_at := old.created_at;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_pets_before_update on public.pets;
create trigger trg_pets_before_update
  before update on public.pets
  for each row execute function public.pets_before_update();

-- ============================================================
-- RLS: deny-by-default; yalnızca sahibi (owner_id = auth.uid()).
-- ============================================================
alter table public.pets enable row level security;

revoke all on public.pets from anon;
revoke all on public.pets from authenticated;
grant select, insert, update, delete on public.pets to authenticated;

drop policy if exists pets_select_own on public.pets;
create policy pets_select_own on public.pets
  for select to authenticated
  using (owner_id = (select auth.uid()));

-- INSERT: yalnızca kendi adına (owner_id = auth.uid()).
drop policy if exists pets_insert_own on public.pets;
create policy pets_insert_own on public.pets
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

-- UPDATE: yalnızca kendi peti; owner_id devri WITH CHECK + trigger ile engellenir.
drop policy if exists pets_update_own on public.pets;
create policy pets_update_own on public.pets
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

-- DELETE: yalnızca kendi peti.
drop policy if exists pets_delete_own on public.pets;
create policy pets_delete_own on public.pets
  for delete to authenticated
  using (owner_id = (select auth.uid()));
