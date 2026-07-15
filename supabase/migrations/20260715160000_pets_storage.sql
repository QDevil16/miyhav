-- ============================================================
-- Miyhav · Migration 0004 — pet profil fotoğrafı Storage (özel bucket + RLS)
-- Amaç: 'pets' PRIVATE bucket; nesne yolu {userId}/{petId}/profile.jpg. Storage
--   RLS: yalnızca sahibi (yolun ilk klasörü = auth.uid()) upload/read/update/delete
--   yapabilir. Sosyal/CDN/public erişim YOK.
-- Not: Mevcut migration dosyaları RETROAKTİF DEĞİŞTİRİLMEZ; bu ayrı, sıralı migration.
-- Not: storage.objects üzerinde RLS Supabase'de zaten AÇIKTIR; burada yalnızca
--   'pets' bucket'ına özel owner-only politikalar eklenir.
-- ============================================================

-- ---------- Bucket (private) ----------
insert into storage.buckets (id, name, public)
values ('pets', 'pets', false)
on conflict (id) do nothing;

-- ---------- Storage RLS: yalnızca sahibi (path[1] = auth.uid()) ----------
-- SELECT (okuma / signed URL üretimi sahiplik gerektirir)
drop policy if exists "pets_media_owner_select" on storage.objects;
create policy "pets_media_owner_select" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'pets'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- INSERT (upload)
drop policy if exists "pets_media_owner_insert" on storage.objects;
create policy "pets_media_owner_insert" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'pets'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- UPDATE (üzerine yazma / upsert)
drop policy if exists "pets_media_owner_update" on storage.objects;
create policy "pets_media_owner_update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'pets'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'pets'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- DELETE (fotoğraf silme)
drop policy if exists "pets_media_owner_delete" on storage.objects;
create policy "pets_media_owner_delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'pets'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
