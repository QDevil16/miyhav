-- ============================================================
-- YEREL TEST SHIM'i — YALNIZCA yerel PostgreSQL'de RLS testleri içindir.
-- PRODUCTION'A/SUPABASE'E UYGULANMAZ. Supabase'in sağladığı auth şeması,
-- auth.uid() ve roller burada minimal biçimde taklit edilir ki migration'lar ve
-- RLS politikaları gerçek Postgres'te koşturulabilsin.
-- Çalıştırma sırası: bu shim → migration'lar → test dosyaları.
-- ============================================================
create extension if not exists pgcrypto;

create schema if not exists auth;

create table if not exists auth.users (
  id uuid primary key default gen_random_uuid(),
  email text,
  raw_user_meta_data jsonb not null default '{}'::jsonb
);

-- Supabase auth.uid(): request.jwt.claims->>'sub'
create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claims', true)::jsonb ->> 'sub', '')::uuid;
$$;

do $$ begin
  create role anon;
exception when duplicate_object then null; end $$;

do $$ begin
  create role authenticated;
exception when duplicate_object then null; end $$;

grant usage on schema auth to anon, authenticated;
grant usage on schema public to anon, authenticated;
