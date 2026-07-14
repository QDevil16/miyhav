-- ============================================================
-- Miyhav · Migration 0001 — profiles
-- Amaç: Kullanıcı profili tablosu, güvenli varsayılanlar, case-insensitive
--       username benzersizliği, idempotent profil oluşturma trigger'ı ve
--       deny-by-default RLS (kullanıcı yalnızca kendi profilini okur/sınırlı
--       günceller).
-- Not:  Bu migration YALNIZCA profiles kapsamındadır. Diğer tablolar (pets,
--       friendships, health_* ...) sonraki görevlerde ayrı migration'larla gelir.
-- ============================================================

-- gen_random_uuid() için (Supabase'de genelde mevcut; güvenli olması için).
create extension if not exists pgcrypto;

-- ---------- Enum türleri (kapalı, durağan kümeler) ----------
do $$ begin
  create type public.profile_visibility as enum ('public', 'friends_only', 'private');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.membership_type as enum ('free', 'premium', 'family');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.account_status as enum ('active', 'suspended', 'deleted');
exception when duplicate_object then null; end $$;

-- ---------- profiles tablosu ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  username text,
  -- Case-insensitive benzersizlik için türetilmiş kolon (client set edemez).
  username_normalized text generated always as (lower(btrim(username))) stored,
  profile_photo_path text,
  short_bio text,
  city text,
  profile_visibility public.profile_visibility not null default 'private',
  membership_type public.membership_type not null default 'free',
  account_status public.account_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint profiles_username_format check (
    username is null
    or (char_length(username) between 3 and 30 and username ~ '^[A-Za-z0-9_]+$')
  ),
  constraint profiles_display_name_len check (
    display_name is null or char_length(display_name) <= 60
  ),
  constraint profiles_short_bio_len check (
    short_bio is null or char_length(short_bio) <= 300
  ),
  constraint profiles_city_len check (
    city is null or char_length(city) <= 80
  )
);

comment on table public.profiles is
  'Kullanıcı profili. id = auth.users.id. Kritik alanlar (membership_type, '
  'account_status, id, created_at) normal kullanıcı tarafından değiştirilemez.';

-- Case-insensitive username benzersizliği. NULL username'ler serbest (birden çok
-- kullanıcı username seçmeden var olabilir; NULL'lar unique index'te ayrık sayılır).
create unique index if not exists profiles_username_normalized_key
  on public.profiles (username_normalized);

-- ============================================================
-- Trigger 1: updated_at bakımı + kritik alanların değişmezliği (BEFORE UPDATE)
-- Normal kullanıcı update'inde id / membership_type / account_status / created_at
-- eski değerine sabitlenir; girişim sessizce yok sayılır. (username_normalized
-- zaten generated olduğu için doğrudan set edilemez.) Üyelik/durum değişimleri
-- ileride ayrı güvenli SECURITY DEFINER RPC'lerle yapılacaktır.
-- ============================================================
create or replace function public.profiles_before_update()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.id := old.id;
  new.membership_type := old.membership_type;
  new.account_status := old.account_status;
  new.created_at := old.created_at;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_before_update on public.profiles;
create trigger trg_profiles_before_update
  before update on public.profiles
  for each row execute function public.profiles_before_update();

-- ============================================================
-- Trigger 2: handle_new_user (AFTER INSERT on auth.users)
-- SECURITY DEFINER gerekçesi: Yeni kullanıcı auth.users'a eklendiğinde profil
-- kaydı, RLS'ten bağımsız ve fonksiyon sahibinin (postgres) yetkisiyle güvenli
-- oluşturulmalıdır; istemcinin başarısına bağlı değildir. Fonksiyon minimum işi
-- yapar (yalnızca public.profiles insert), search_path='' ile sabitlenir ve
-- tüm nesneler tam nitelikli yazılır.
--
-- Güvenlik: Kullanıcı metadata'sına KÖRÜ KÖRÜNE GÜVENİLMEZ. Yalnızca display_name
-- metadata'dan alınır (trim + 60 karakter sınırı + boşsa NULL). username,
-- profile_visibility, membership_type, account_status metadata'dan ALINMAZ;
-- tablo varsayılanları (private/free/active) kullanılır. Idempotent: on conflict
-- do nothing.
-- ============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    nullif(btrim(left(coalesce(new.raw_user_meta_data ->> 'display_name', ''), 60)), '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- RLS: deny-by-default. En küçük yetki.
-- ============================================================
alter table public.profiles enable row level security;

-- Geniş varsayılan grant'leri kaldır, yalnızca gerekli olanı ver.
revoke all on public.profiles from anon;
revoke all on public.profiles from authenticated;
grant select, update on public.profiles to authenticated;

-- Kullanıcı yalnızca KENDİ profilini okur. (Başkalarının profilleri bu aşamada
-- genel okumaya AÇILMAZ; arama/keşif sonraki görevlerde view/RPC ile gelir.)
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = (select auth.uid()));

-- Kullanıcı yalnızca kendi profilini günceller. Kritik alan değişmezliği
-- yukarıdaki BEFORE UPDATE trigger'ı ile garanti edilir.
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- INSERT / DELETE için authenticated'a policy YOK → deny. Profil oluşturma
-- yalnızca handle_new_user trigger'ı ile; silme hesap silme RPC'si ile (ileride).
