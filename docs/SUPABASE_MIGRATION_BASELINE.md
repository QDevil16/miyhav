# SUPABASE_MIGRATION_BASELINE — Migration history baseline planı

Bu doküman, `20260714093000_create_profiles` migration'ının uzak **development**
Supabase projesinde **SQL Editor üzerinden** uygulanması sonrası ortaya çıkan
migration-history uyumsuzluğunu **güvenli biçimde** kapatma (baseline) planıdır.

> Kapsam: yalnızca `20260714093000_create_profiles`. Şema TEKRAR UYGULANMAZ.
> Migration SQL dosyası DEĞİŞTİRİLMEZ.

## 1. Durum (neden baseline gerekli?)
- Şema (`profiles` tablosu, enum'lar, trigger'lar, RLS politikaları) uzak
  development DB'sine **başarıyla uygulandı** — ancak SQL Editor kullanıldığı için
  Supabase'in migration geçmişi tablosu (`supabase_migrations.schema_migrations`)
  bu sürümü **içermiyor**.
- Sonuç: yerel `supabase/migrations/` ile uzak history **uyumsuz**. CLI, bu sürümü
  "uygulanmamış" sanır.
- Risk: Bir sonraki `supabase db push`, bu migration'ı **tekrar** uygulamaya
  çalışır. (Migration büyük ölçüde idempotent yazılmış olsa da, history'nin
  gerçeği yansıtması esastır; senkron olmayan history ileride yanlış sıralama/
  tekrar uygulama ve kafa karışıklığı üretir.)

## 2. Hedef
Uzak history'ye `20260714093000` sürümünü **şemayı yeniden çalıştırmadan**
"applied" olarak işaretlemek (resmi `supabase migration repair`), böylece:
- `supabase migration list` → Local ve Remote **senkron**,
- gelecekteki `supabase db push` bu migration'ı **tekrar uygulamaz**,
- yeni migration'lar (AUTH-001 vb.) normal akışla eklenebilir.

## 3. Ön doğrulama (CLI gerekmez — SQL Editor)
Baseline'dan önce, uzak DB'nin migration ile **aynı** olduğunu doğrula:
1. Supabase → **SQL Editor** → `supabase/checks/verify_remote_profiles.sql`
   dosyasının içeriğini çalıştır (SALT OKUNUR; hiçbir şeyi değiştirmez).
2. **Bölüm 1**: tüm satırlar `OK` olmalı. `EKSİK` varsa → baseline'a geçme,
   önce eksik nesne araştırılır.
3. **Bölüm 2** (Messages/Notices): büyük olasılıkla
   `BASELINE GEREKLI: ... history 20260714093000 icermiyor` yazacaktır. Bu
   beklenen durumdur ve 4. adımın gerekçesidir.

## 4. Baseline (CLI erişimi olan bir makinede — ör. Windows PowerShell)
> Bu geliştirme (cloud) ortamının egress politikası `*.supabase.co`'yu engeller;
> bu adımlar CLI erişimi olan kullanıcı makinesinde yapılır. Parola/token sohbete
> yazılmaz, dosyaya kaydedilmez; yalnızca terminalin kendi interaktif isteminde
> veya tarayıcı login akışında girilir.

Proje kökünde (repo klasörü, `supabase/` burada):
```powershell
# 1) Giriş (tarayıcı login akışı; token'ı hiçbir yere yazma)
npx supabase login

# 2) Uzak projeye bağla (DB password terminalin kendi isteminde girilir)
npx supabase link --project-ref ckocodjkvwzqyyilbqli

# 3) BASELINE: şemayı çalıştırmadan history'ye 'applied' olarak işaretle
npx supabase migration repair --status applied 20260714093000

# 4) Senkron doğrulaması: Local ve Remote aynı sürümü göstermeli
npx supabase migration list

# 5) (Opsiyonel) Şema farkı yok doğrulaması — çıktı boşsa şema history ile birebir
npx supabase db diff
```

## 5. Baseline sonrası kurallar
- `supabase db push` yalnızca **repair sonrası** çalıştırılır (repair'den önce
  ASLA — tekrar uygulama riski).
- Bundan sonra şema değişiklikleri **yalnızca yeni migration dosyalarıyla** yapılır;
  uzak DB'de doğrudan SQL Editor ile kalıcı şema değişikliği yapılmaz (baseline'ı
  yeniden bozar).
- `20260714093000_create_profiles.sql` içeriği **değiştirilmez** (uygulanmış bir
  migration'ın içeriği değiştirilirse history ile checksum/uyum bozulur).

## 6. Takip
Bu iş, tamamlanana kadar açık **operasyon/test borcu**dur:
`docs/TASKS.md` → Test Borcu → **OPS-001**. Kapatma koşulu: 4. adımdaki
`supabase migration list` çıktısında `20260714093000` hem Local hem Remote'ta
görünür ve `supabase db diff` fark üretmez.
