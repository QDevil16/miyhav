-- ============================================================
-- YEREL TEST SHIM'i (Storage) — YALNIZCA yerel PostgreSQL'de Storage RLS testleri
-- içindir. PRODUCTION'A UYGULANMAZ. Supabase'in sağladığı storage şeması,
-- storage.objects/buckets ve storage.foldername() minimal biçimde taklit edilir.
-- Çalıştırma sırası: _shim_local.sql → BU dosya → migration'lar → test dosyaları.
-- ============================================================
create schema if not exists storage;

create table if not exists storage.buckets (
  id text primary key,
  name text not null,
  public boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text not null references storage.buckets (id),
  name text not null,
  owner uuid,
  created_at timestamptz not null default now()
);

-- Supabase storage.foldername(name): yolu '/' ile böler, SON parçayı (dosya adı)
-- çıkarır → klasör dizisini döndürür. '{u}/{p}/profile.jpg' → {'{u}','{p}'}.
create or replace function storage.foldername(name text)
returns text[]
language sql
immutable
as $$
  select (string_to_array(name, '/'))[
    1 : greatest(array_length(string_to_array(name, '/'), 1) - 1, 0)
  ];
$$;

-- Supabase'de storage.objects RLS AÇIKTIR; yerelde de açıyoruz ki politikalar
-- gerçekten zorlansın.
alter table storage.objects enable row level security;

grant usage on schema storage to anon, authenticated;
grant select, insert, update, delete on storage.objects to authenticated;
grant select on storage.buckets to authenticated;
