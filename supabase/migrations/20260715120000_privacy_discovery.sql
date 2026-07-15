-- ============================================================
-- Miyhav · Migration 0002 — profil gizliliği + güvenli keşif projeksiyonu
-- Amaç:
--  1) Full-profile SELECT RLS'i ürün kuralına göre genişlet: public+aktif
--     profiller authenticated+aktif kullanıcılarca okunabilir; friends_only ve
--     private tam profili yalnızca sahibine açık kalır (friends erişimi FRIEND
--     görevine ertelendi → deny-by-default).
--  2) Keşif/arama için GÜVENLİ, sınırlı projeksiyon: yalnızca 5 güvenli kolon.
--     friends_only profiller keşifte BULUNABİLİR ama tam profilleri açılmaz
--     ("aramada bulunma" ≠ "tam profil erişimi").
-- Not: 20260714093000_create_profiles.sql RETROAKTİF DEĞİŞTİRİLMEZ.
-- ============================================================

-- ---------- Yardımcı: hesap aktif mi? ----------
-- SECURITY DEFINER: RLS'ten bağımsız yalnızca boolean döner; hassas veri sızdırmaz.
create or replace function public.is_account_active(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = uid and p.account_status = 'active'
  );
$$;

revoke all on function public.is_account_active(uuid) from public;
grant execute on function public.is_account_active(uuid) to authenticated;

-- ============================================================
-- Full-profile SELECT: mevcut profiles_select_own (kendi kaydı) KORUNUR; buna EK
-- olarak public + aktif profiller, aktif authenticated kullanıcılarca okunur.
-- (Politikalar OR'lanır.) friends_only / private → yalnızca sahibi.
-- ============================================================
drop policy if exists profiles_select_public on public.profiles;
create policy profiles_select_public on public.profiles
  for select to authenticated
  using (
    account_status = 'active'
    and profile_visibility = 'public'
    and public.is_account_active((select auth.uid()))
  );

-- ============================================================
-- Keşif/arama projeksiyonu (GÜVENLİ, sınırlı).
-- SECURITY DEFINER view: full-profile RLS'i baypas ederek yalnızca aşağıdaki 5
-- güvenli kolonu, yalnızca keşfedilebilir (public|friends_only) + aktif profiller
-- için döndürür. E-posta/auth/sağlık/üyelik/durum GİBİ hassas alanlar KESİNLİKLE
-- yer almaz. private ve aktif olmayan profiller projeksiyonda BULUNMAZ.
-- Gerekçe (D-005 rafine): SECURITY INVOKER view friends_only'i göstermek için
-- full-profile satır RLS'ini açmayı gerektirir → tam profil sızar. Bu yüzden
-- kolonları allow-list'leyen SECURITY DEFINER projeksiyon kullanılır.
-- ============================================================
drop view if exists public.public_profiles;
create view public.public_profiles
with (security_invoker = false)
as
  select
    p.id,
    p.username,
    p.display_name,
    p.profile_photo_path,
    p.profile_visibility
  from public.profiles p
  where p.account_status = 'active'
    and p.profile_visibility in ('public', 'friends_only');

revoke all on public.public_profiles from anon, authenticated, public;
grant select on public.public_profiles to authenticated;

-- ---------- Prefix arama için index (username_normalized) ----------
-- Exact eşleşme mevcut unique index'i kullanır; prefix (LIKE 'x%') için
-- text_pattern_ops index eklenir (collation'dan bağımsız index kullanımı).
create index if not exists profiles_username_normalized_prefix
  on public.profiles (username_normalized text_pattern_ops);

-- ============================================================
-- Arama RPC temeli (DISCOVERY görevleri kullanacak). SECURITY DEFINER; yalnızca
-- 5 güvenli kolon döner. private/aktif-değil hariç; çağıranın kendisi hariç;
-- username üzerinde case-insensitive prefix arama; sınırlı sonuç.
-- ============================================================
create or replace function public.search_profiles(search text)
returns table (
  id uuid,
  username text,
  display_name text,
  profile_photo_path text,
  profile_visibility public.profile_visibility
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    p.id,
    p.username,
    p.display_name,
    p.profile_photo_path,
    p.profile_visibility
  from public.profiles p
  where p.account_status = 'active'
    and p.profile_visibility in ('public', 'friends_only')
    and p.id <> (select auth.uid())
    and p.username_normalized is not null
    and btrim(coalesce(search, '')) <> ''
    and p.username_normalized like lower(btrim(search)) || '%'
  order by p.username_normalized
  limit 30;
$$;

revoke all on function public.search_profiles(text) from public;
grant execute on function public.search_profiles(text) to authenticated;
