# TEST_STRATEGY — Test Yaklaşımı

## İlke
Gerçekte çalıştırılmayan test "geçti" sayılmaz. Test dosyasının varlığı testin
çalıştığı anlamına gelmez. "All tests passed" ancak gerçek komut çıktısı görülünce
söylenir.

## Test Katmanları
1. **Dart/Flutter unit testleri** — saf domain servisleri (özellikle periyot/
   `next_due_date` hesaplaması: ay sonları, Şubat, artık yıl, 29/30/31 gün, zaman
   dilimi, düzenleme/silme/tekrar kapatma, duplicate reminder engeli), model
   dönüşümleri, ErrorMapper.
2. **Flutter widget testleri** — kritik bileşen ve akış davranışları.
3. **SQL migration kontrolleri** — migration'ların temiz veritabanına uygulanması.
4. **RLS / database testleri** — aşağıdaki senaryolar gerçek çalıştırılır.
5. **Edge Function lint + testleri** — bildirim/hesap silme fonksiyonları.
6. **Build doğrulaması** — build/native/dependency etkileyen görevlerde Android
   debug build; ilgili yayın görevlerinde release/iOS build.

## Zorunlu RLS Senaryoları
- Kullanıcı kendi profilini okur; başkası private profili okuyamaz.
- friends_only profil aramada görünür; tam profil arkadaş olmayana açılmaz;
  kabul edilmiş arkadaş açabilir.
- Kullanıcı başka kullanıcı adına pet oluşturamaz; pets.owner_id değiştirilemez.
- Sağlık kaydı yalnızca pet sahibi tarafından okunur; arkadaş ve public okuyamaz.
- Kendine friend request gönderilemez; duplicate ve reverse-duplicate oluşamaz;
  receiver kabul edebilir; üçüncü kullanıcı ilişkiyi değiştiremez.
- Blocked kullanıcı profil/post/etkileşime erişemez.

## RLS Test Yaklaşımı
Tercih: **Supabase CLI + yerel Docker Postgres** üzerinde migration'ları uygulayıp
farklı JWT/rol bağlamlarıyla policy davranışını doğrulamak (pgTAP veya SQL tabanlı
assert'ler). Uygun görevde kurulur.

## Ortam Eksikse
Docker / Supabase CLI / test ortamı yoksa:
1. Açıkça Türkçe bildir. 2. Görevi tam test edilmiş SAYMA. 3. `docs/TASKS.md`'e
açık **test borcu** yaz. 4. Ortamın nasıl kurulacağını basit Türkçe anlat.

## Görev Bazlı Kapsam
Her görevde yalnızca ilgili testler koşulur; ama temel doğrulamalar (dart format,
flutter analyze, ilgili flutter test) atlanmaz. Her küçük görevde tüm ağır build'ler
çalıştırılmaz.
