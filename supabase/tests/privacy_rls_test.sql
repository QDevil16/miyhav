-- ============================================================
-- Miyhav · RLS testleri — profil gizliliği + keşif projeksiyonu (PRIVACY-001)
-- Ön koşul: _shim_local.sql + migration'lar uygulanmış olmalı.
-- Çalıştırma: psql ... -v ON_ERROR_STOP=1 -f privacy_rls_test.sql
-- Herhangi bir assert başarısız olursa script hata ile durur.
-- ============================================================
\set ON_ERROR_STOP on

-- Test kullanıcıları (trigger profilleri private/active oluşturur).
insert into auth.users (id) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'), -- pub (public, active)
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'), -- fr  (friends_only, active)
  ('cccccccc-cccc-cccc-cccc-cccccccccccc'), -- prv (private, active)
  ('dddddddd-dddd-dddd-dddd-dddddddddddd'), -- inact (public, suspended)
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee')  -- viewer (active, private)
on conflict (id) do nothing;

-- Fixture kurulumu: account_status/visibility'yi ayarlamak için before_update
-- trigger'ı GEÇİCİ olarak devre dışı (yalnızca test setup; trigger davranışı
-- ayrıca test edilir). username'ler de burada verilir.
alter table public.profiles disable trigger trg_profiles_before_update;
update public.profiles set profile_visibility='public',       username='AdaPub'   where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
update public.profiles set profile_visibility='friends_only',  username='BoraFr'   where id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
update public.profiles set profile_visibility='private',       username='CemPrv'   where id='cccccccc-cccc-cccc-cccc-cccccccccccc';
update public.profiles set profile_visibility='public', account_status='suspended', username='DenizInact' where id='dddddddd-dddd-dddd-dddd-dddddddddddd';
alter table public.profiles enable trigger trg_profiles_before_update;

-- ---------- 1) Owner kendi private profilini okur ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"cccccccc-cccc-cccc-cccc-cccccccccccc"}', true);
  select count(*) into c from public.profiles where id='cccccccc-cccc-cccc-cccc-cccccccccccc';
  assert c=1, '1) owner kendi private profilini okuyamadı';
end $$;

-- ---------- 2) Başka kullanıcı private profili okuyamaz ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  select count(*) into c from public.profiles where id='cccccccc-cccc-cccc-cccc-cccccccccccc';
  assert c=0, '2) private profil başkasına açıldı (RLS ihlali)';
end $$;

-- ---------- 3) Public aktif profil, aktif authenticated tarafından okunur ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  select count(*) into c from public.profiles where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  assert c=1, '3) public aktif profil okunamadı';
end $$;

-- ---------- 4) Inactive public profil başkasına açılmaz ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  select count(*) into c from public.profiles where id='dddddddd-dddd-dddd-dddd-dddddddddddd';
  assert c=0, '4) inactive public profil başkasına açıldı';
end $$;

-- ---------- 16) friends_only tam profili arkadaş olmayana kapalı (deny-by-default) ----------
do $$
declare c int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  select count(*) into c from public.profiles where id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  assert c=0, '16) friends_only tam profil arkadaş olmayana açıldı (friendship yok → deny olmalı)';
end $$;

-- ---------- 5,6,7,8) Discovery projeksiyonu (public_profiles) ----------
do $$
declare has_pub int; has_fr int; has_prv int; has_inact int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  select count(*) into has_pub   from public.public_profiles where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  select count(*) into has_fr    from public.public_profiles where id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  select count(*) into has_prv   from public.public_profiles where id='cccccccc-cccc-cccc-cccc-cccccccccccc';
  select count(*) into has_inact from public.public_profiles where id='dddddddd-dddd-dddd-dddd-dddddddddddd';
  assert has_pub=1,   '6) public profil discovery içinde yok';
  assert has_fr=1,    '5) friends_only profil discovery içinde yok';
  assert has_prv=0,   '7) private profil discovery içinde bulundu';
  assert has_inact=0, '8) inactive profil discovery içinde bulundu';
end $$;

-- ---------- 9,10,11) Projeksiyon yalnızca izin verilen kolonları döndürür ----------
do $$
declare cols text[]; disallowed int;
begin
  select array_agg(column_name order by column_name) into cols
  from information_schema.columns
  where table_schema='public' and table_name='public_profiles';
  assert cols = array['display_name','id','profile_photo_path','profile_visibility','username'],
    '9) discovery projeksiyon kolonları beklenenden farklı: ' || cols::text;
  select count(*) into disallowed
  from information_schema.columns
  where table_schema='public' and table_name='public_profiles'
    and column_name in ('membership_type','account_status','email','short_bio','city','username_normalized','created_at','updated_at');
  assert disallowed=0, '10/11) discovery projeksiyonunda yasak kolon var (membership_type/account_status vb.)';
end $$;

-- ---------- search_profiles: private/inactive hariç, güvenli kolonlar ----------
do $$
declare c_pub int; c_prv int; c_self int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  -- 'ada' → AdaPub (public) bulunur
  select count(*) into c_pub from public.search_profiles('ada') where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  assert c_pub=1, 'search_profiles public prefix eşleşmesini döndürmedi';
  -- 'cem' → CemPrv (private) BULUNMAZ
  select count(*) into c_prv from public.search_profiles('cem');
  assert c_prv=0, 'search_profiles private profili döndürdü';
  -- 'bora' → BoraFr (friends_only) bulunur (keşifte bulunabilir)
  select count(*) into c_pub from public.search_profiles('bora') where id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  assert c_pub=1, 'search_profiles friends_only profili döndürmedi (keşifte bulunmalı)';
end $$;

-- ---------- 12) Başka kullanıcı profile update yapamaz ----------
do $$
declare v_name text;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  update public.profiles set display_name='hack' where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  -- RLS update policy yalnızca own → 0 satır etkilenir.
  reset role;
  select display_name into v_name from public.profiles where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  assert v_name is distinct from 'hack', '12) başka kullanıcı profili güncelleyebildi';
end $$;

-- ---------- 13,14) Owner membership_type/account_status değiştiremez ----------
do $$
declare v_mem public.membership_type; v_st public.account_status;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"}', true);
  update public.profiles
     set membership_type='premium', account_status='suspended', display_name='AdaX'
   where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  select membership_type, account_status into v_mem, v_st
  from public.profiles where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  assert v_mem='free',   '13) owner membership_type değiştirebildi';
  assert v_st='active',  '14) owner account_status değiştirebildi';
end $$;

-- ---------- 15) Username case-insensitive unique constraint ----------
do $$
declare violated boolean := false;
begin
  set local role authenticated;
  perform set_config('request.jwt.claims', '{"sub":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', true);
  begin
    -- viewer, AdaPub'ın username'ini farklı harf büyüklüğüyle almaya çalışır.
    update public.profiles set username='adapub' where id='eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
  exception when unique_violation then
    violated := true;
  end;
  assert violated, '15) case-insensitive username unique constraint korunmadı';
end $$;

-- Tümü geçtiyse:
do $$ begin raise notice 'PRIVACY-001 RLS testleri: TÜMÜ GEÇTİ'; end $$;
