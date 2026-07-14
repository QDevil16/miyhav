-- ============================================================
-- Miyhav · Uzak DB doğrulama (SALT OKUNUR) — 20260714093000_create_profiles
-- Amaç: Uzak development veritabanının bu migration ile AYNI durumda olduğunu
--       doğrulamak. Bu betik hiçbir nesne oluşturmaz/değiştirmez; yalnızca SELECT.
-- Kullanım: Supabase SQL Editor'da tümünü çalıştır. Bölüm 1'de her satır 'OK'
--           olmalı; 'EKSİK' varsa şema beklenenle uyuşmuyor demektir.
-- Not: Şemayı TEKRAR UYGULAMAZ. Yalnızca mevcut durumu raporlar.
-- ============================================================

-- ---------- Bölüm 1: Şema nesneleri migration ile aynı mı? ----------
with checks as (
  select 'extension: pgcrypto' as kontrol,
         exists (select 1 from pg_extension where extname = 'pgcrypto') as gecti
  union all
  select 'enum: profile_visibility',
         exists (select 1 from pg_type
                 where typname = 'profile_visibility'
                   and typnamespace = 'public'::regnamespace)
  union all
  select 'enum: membership_type',
         exists (select 1 from pg_type
                 where typname = 'membership_type'
                   and typnamespace = 'public'::regnamespace)
  union all
  select 'enum: account_status',
         exists (select 1 from pg_type
                 where typname = 'account_status'
                   and typnamespace = 'public'::regnamespace)
  union all
  select 'table: public.profiles',
         exists (select 1 from pg_tables
                 where schemaname = 'public' and tablename = 'profiles')
  union all
  select 'kolon: username_normalized (generated)',
         exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'profiles'
                   and column_name = 'username_normalized'
                   and is_generated = 'ALWAYS')
  union all
  select 'default: profile_visibility = private',
         exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'profiles'
                   and column_name = 'profile_visibility'
                   and column_default like '%private%')
  union all
  select 'default: membership_type = free',
         exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'profiles'
                   and column_name = 'membership_type'
                   and column_default like '%free%')
  union all
  select 'default: account_status = active',
         exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'profiles'
                   and column_name = 'account_status'
                   and column_default like '%active%')
  union all
  select 'index (unique): profiles_username_normalized_key',
         exists (select 1 from pg_indexes
                 where schemaname = 'public'
                   and indexname = 'profiles_username_normalized_key')
  union all
  select 'function: public.handle_new_user',
         exists (select 1 from pg_proc p
                 join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname = 'public' and p.proname = 'handle_new_user')
  union all
  select 'function: public.profiles_before_update',
         exists (select 1 from pg_proc p
                 join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname = 'public' and p.proname = 'profiles_before_update')
  union all
  select 'trigger: trg_profiles_before_update (public.profiles)',
         exists (select 1 from pg_trigger
                 where tgname = 'trg_profiles_before_update' and not tgisinternal)
  union all
  select 'trigger: on_auth_user_created (auth.users)',
         exists (select 1 from pg_trigger
                 where tgname = 'on_auth_user_created' and not tgisinternal)
  union all
  select 'RLS aktif: public.profiles',
         exists (select 1 from pg_class c
                 join pg_namespace n on n.oid = c.relnamespace
                 where n.nspname = 'public' and c.relname = 'profiles'
                   and c.relrowsecurity)
  union all
  select 'policy: profiles_select_own',
         exists (select 1 from pg_policies
                 where schemaname = 'public' and tablename = 'profiles'
                   and policyname = 'profiles_select_own')
  union all
  select 'policy: profiles_update_own',
         exists (select 1 from pg_policies
                 where schemaname = 'public' and tablename = 'profiles'
                   and policyname = 'profiles_update_own')
)
select kontrol,
       case when gecti then 'OK' else 'EKSİK' end as durum
from checks
order by (case when gecti then 1 else 0 end), kontrol;

-- ---------- Bölüm 2: Migration history baseline durumu ----------
-- Not: supabase_migrations şeması, CLI hiç link/repair yapmadıysa OLMAYABİLİR.
-- Bu blok şema yoksa da güvenli çalışır (to_regclass ile korunur) ve mesaj
-- olarak sonucu 'Messages' / 'Notices' bölümünde gösterir.
do $$
declare v_var boolean;
begin
  if to_regclass('supabase_migrations.schema_migrations') is null then
    raise notice 'BASELINE GEREKLI: supabase_migrations.schema_migrations tablosu YOK (CLI henuz link/repair yapmamis).';
    return;
  end if;
  execute 'select exists (select 1 from supabase_migrations.schema_migrations where version = $1)'
    into v_var using '20260714093000';
  if v_var then
    raise notice 'BASELINE TAMAM: migration history 20260714093000 sürümünü iceriyor.';
  else
    raise notice 'BASELINE GEREKLI: migration history 20260714093000 sürümünü ICERMIYOR (SQL Editor ile uygulandi).';
  end if;
end $$;
