-- ============================================================
-- Miyhav · RLS testleri — pets (PET-001)
-- Ön koşul: _shim_local.sql + migration'lar uygulanmış olmalı.
-- Çalıştırma: psql ... -v ON_ERROR_STOP=1 -f pets_rls_test.sql
-- ============================================================
\set ON_ERROR_STOP on

insert into auth.users (id) values
  ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1'), -- sahip
  ('b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2')  -- başkası
on conflict (id) do nothing;

-- ---------- 1) Sahip kendi adına pet ekler ----------
do $$
declare v_id uuid;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"}', true);
  insert into public.pets (owner_id, name, species)
  values ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'Pamuk', 'cat')
  returning id into v_id;
  assert v_id is not null, '1) sahip kendi petini ekleyemedi';
end $$;

-- ---------- 2) Başka kullanıcı adına pet EKLENEMEZ (owner_id spoof) ----------
do $$
declare v_err boolean := false;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"}', true);
  begin
    insert into public.pets (owner_id, name, species)
    values ('b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2', 'Sahte', 'dog');
  exception when insufficient_privilege or check_violation then
    v_err := true;
  end;
  assert v_err, '2) kullanıcı başkası adına pet ekleyebildi (owner_id spoof)';
end $$;

-- ---------- 3) Başka kullanıcı sahibin petini okuyamaz ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2"}', true);
  select count(*) into c from public.pets where owner_id='a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1';
  assert c=0, '3) başka kullanıcı sahibin petini okuyabildi (RLS ihlali)';
end $$;

-- ---------- 4) Sahip kendi petini okur ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"}', true);
  select count(*) into c from public.pets where owner_id='a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1';
  assert c=1, '4) sahip kendi petini okuyamadı';
end $$;

-- ---------- 5) owner_id GÜNCELLEMEDE değiştirilemez (devredilemez) ----------
do $$
declare v_owner uuid;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"}', true);
  update public.pets
     set owner_id='b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2', name='PamukX'
   where owner_id='a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1';
  reset role;
  select owner_id into v_owner from public.pets where name='PamukX';
  assert v_owner='a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', '5) owner_id başka kullanıcıya devredilebildi';
end $$;

-- ---------- 6) Başka kullanıcı sahibin petini güncelleyemez/silemez ----------
do $$
declare c int; v_name text;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2"}', true);
  update public.pets set name='hack' where name='PamukX';   -- 0 satır (RLS)
  delete from public.pets where name='PamukX';               -- 0 satır (RLS)
  reset role;
  select count(*) into c from public.pets where name='PamukX';
  assert c=1, '6a) başka kullanıcı sahibin petini sildi';
  select name into v_name from public.pets where owner_id='a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1';
  assert v_name='PamukX', '6b) başka kullanıcı sahibin petini güncelledi';
end $$;

-- ---------- 7) Geçersiz species reddedilir (check constraint) ----------
do $$
declare v_err boolean := false;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"}', true);
  begin
    insert into public.pets (owner_id, name, species)
    values ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'Geçersiz', 'dinozor');
  exception when check_violation then
    v_err := true;
  end;
  assert v_err, '7) geçersiz species kabul edildi';
end $$;

-- ---------- 8) Sahip kendi petini silebilir ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"}', true);
  delete from public.pets where owner_id='a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1';
  select count(*) into c from public.pets where owner_id='a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1';
  assert c=0, '8) sahip kendi petini silemedi';
end $$;

do $$ begin raise notice 'PET-001 RLS testleri: TÜMÜ GEÇTİ'; end $$;
