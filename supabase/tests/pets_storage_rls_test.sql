-- ============================================================
-- Miyhav · Storage RLS testleri — pet profil fotoğrafı (PET-MEDIA-001)
-- Ön koşul: _shim_local.sql + _shim_storage_local.sql + migration'lar uygulanmış.
-- Yol modeli: pets bucket, nesne adı '{userId}/{petId}/profile.jpg'.
-- ============================================================
\set ON_ERROR_STOP on

-- Test kullanıcıları (auth.users; UUID sabit)
insert into auth.users (id) values
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1'), -- sahip
  ('d2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2')  -- başkası
on conflict (id) do nothing;

-- ---------- 1) Sahip kendi yoluna upload edebilir ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1"}', true);
  insert into storage.objects (bucket_id, name)
  values ('pets', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg');
  select count(*) into c from storage.objects
   where name = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg';
  assert c = 1, '1) sahip kendi yoluna upload edemedi';
end $$;

-- ---------- 2) Başka kullanıcının yoluna upload EDİLEMEZ ----------
do $$
declare v_err boolean := false;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1"}', true);
  begin
    insert into storage.objects (bucket_id, name)
    values ('pets', 'd2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2/petX/profile.jpg');
  exception when insufficient_privilege then
    v_err := true;
  end;
  assert v_err, '2) kullanıcı başkasının yoluna upload edebildi';
end $$;

-- ---------- 3) Başka kullanıcı sahibin dosyasını okuyamaz ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"d2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2"}', true);
  select count(*) into c from storage.objects
   where name = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg';
  assert c = 0, '3) başka kullanıcı sahibin dosyasını okuyabildi';
end $$;

-- ---------- 4) Sahip kendi dosyasını okur ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1"}', true);
  select count(*) into c from storage.objects
   where name = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg';
  assert c = 1, '4) sahip kendi dosyasını okuyamadı';
end $$;

-- ---------- 5) Başka kullanıcı sahibin dosyasını silemez ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"d2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2"}', true);
  delete from storage.objects
   where name = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg';
  reset role;
  select count(*) into c from storage.objects
   where name = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg';
  assert c = 1, '5) başka kullanıcı sahibin dosyasını sildi';
end $$;

-- ---------- 6) Sahip kendi dosyasını silebilir ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1"}', true);
  delete from storage.objects
   where name = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg';
  select count(*) into c from storage.objects
   where name = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1/pet1/profile.jpg';
  assert c = 0, '6) sahip kendi dosyasını silemedi';
end $$;

-- ---------- 7) pets bucket private ----------
do $$
declare v_pub boolean;
begin
  select public into v_pub from storage.buckets where id = 'pets';
  assert v_pub = false, '7) pets bucket public olmamalı';
end $$;

do $$ begin raise notice 'PET-MEDIA-001 Storage RLS testleri: TÜMÜ GEÇTİ'; end $$;
