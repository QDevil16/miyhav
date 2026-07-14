-- ============================================================
-- Miyhav · RLS testleri — profiles
-- Çalıştırma: migration'lar uygulanmış, Supabase benzeri bir ortamda
--   (auth.uid(), authenticated rolü mevcut) psql ile:
--     psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/profiles_rls_test.sql
-- Herhangi bir assert başarısız olursa script hata ile durur.
-- Not: auth.users'a doğrudan insert yalnızca test/local ortamda yapılır.
-- ============================================================
\set ON_ERROR_STOP on

-- Test kullanıcıları (auth.users → trigger profiles oluşturur).
insert into auth.users (id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222')
on conflict (id) do nothing;

-- 1) Trigger idempotent + güvenli varsayılanlar
do $$
declare v_vis public.profile_visibility; v_mem public.membership_type; v_st public.account_status; v_cnt int;
begin
  select profile_visibility, membership_type, account_status
    into v_vis, v_mem, v_st
  from public.profiles where id = '11111111-1111-1111-1111-111111111111';
  assert v_vis = 'private', 'varsayılan gizlilik private değil';
  assert v_mem = 'free', 'varsayılan üyelik free değil';
  assert v_st = 'active', 'varsayılan durum active değil';
  -- Idempotency: handle_new_user'ın kullandığı "on conflict do nothing" mekaniği
  -- ikinci kez çalışsa da mükerrer profil oluşturmamalı (hata da vermemeli).
  insert into public.profiles (id) values ('11111111-1111-1111-1111-111111111111')
    on conflict (id) do nothing;
  select count(*) into v_cnt from public.profiles where id = '11111111-1111-1111-1111-111111111111';
  assert v_cnt = 1, 'idempotency bozuldu (mükerrer profil)';
end $$;

-- 2) Kullanıcı kendi profilini okur, başkasınınkini okuyamaz
do $$
declare v_cnt int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  select count(*) into v_cnt from public.profiles where id = '11111111-1111-1111-1111-111111111111';
  assert v_cnt = 1, 'kullanıcı kendi profilini okuyamadı';
  select count(*) into v_cnt from public.profiles where id = '22222222-2222-2222-2222-222222222222';
  assert v_cnt = 0, 'kullanıcı başkasının profilini okuyabildi (RLS ihlali)';
end $$;

-- 3) İzin verilen alan güncellenir; kritik alanlar değiştirilemez
do $$
declare v_mem public.membership_type; v_st public.account_status; v_name text;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  update public.profiles
     set display_name = 'Ada', city = 'İstanbul',
         membership_type = 'premium', account_status = 'suspended'
   where id = '11111111-1111-1111-1111-111111111111';
  select display_name, membership_type, account_status into v_name, v_mem, v_st
  from public.profiles where id = '11111111-1111-1111-1111-111111111111';
  assert v_name = 'Ada', 'display_name güncellenemedi';
  assert v_mem = 'free', 'membership_type kullanıcı tarafından değiştirilebildi!';
  assert v_st = 'active', 'account_status kullanıcı tarafından değiştirilebildi!';
end $$;

-- 4) Başka kullanıcının profilini güncelleyememe
do $$
declare v_rows int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  with upd as (
    update public.profiles set display_name = 'hack'
    where id = '22222222-2222-2222-2222-222222222222' returning 1
  )
  select count(*) into v_rows from upd;
  assert v_rows = 0, 'kullanıcı başkasının profilini güncelleyebildi (RLS ihlali)';
end $$;

-- 5) INSERT deny (authenticated için insert policy yok)
do $$
declare v_err boolean := false;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  begin
    insert into public.profiles (id) values ('33333333-3333-3333-3333-333333333333');
  exception when insufficient_privilege then v_err := true;
  end;
  assert v_err, 'authenticated kullanıcı doğrudan profil ekleyebildi (deny bozuldu)';
end $$;

-- 6) Case-insensitive username benzersizliği
do $$
declare v_err boolean := false;
begin
  update public.profiles set username = 'Steve'
    where id = '11111111-1111-1111-1111-111111111111';
  begin
    update public.profiles set username = 'steve'
      where id = '22222222-2222-2222-2222-222222222222';
  exception when unique_violation then v_err := true;
  end;
  assert v_err, 'case-insensitive username benzersizliği çalışmadı';
end $$;

\echo '== profiles RLS testleri: TÜMÜ GEÇTİ =='
