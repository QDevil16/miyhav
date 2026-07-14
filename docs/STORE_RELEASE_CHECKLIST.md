# STORE_RELEASE_CHECKLIST — Mağaza Yayın Kontrol Listesi

İlgili görevlerde hazırlanır. Kullanıcı açıkça izin vermeden production yayın yapılmaz.

## Kimlik & Sürüm
- [ ] Miyhav uygulama ikonu (özgün)
- [ ] Splash ekranı
- [ ] Android package name (onaylı — öneri `com.miyhav.app`)
- [ ] iOS bundle identifier (onaylı, package ile tutarlı)
- [ ] Versioning (version name + build number stratejisi)

## İmzalama
- [ ] Android signing (keystore — depoda değil)
- [ ] Codemagic iOS automatic signing (App Store Connect API key)

## Yasal & Gizlilik
- [ ] Privacy Policy (Türkçe)
- [ ] Kullanım Koşulları
- [ ] Topluluk Kuralları
- [ ] Hesap Silme akışı + (gerekirse) web hesap silme talimatı
- [ ] Google Play Data Safety formu
- [ ] Apple privacy declarations (App Privacy)

## İzin Metinleri (Türkçe)
- [ ] Kamera izni metni
- [ ] Fotoğraf izni metni
- [ ] Bildirim izni metni

## Mağaza Varlıkları
- [ ] Türkçe mağaza açıklaması
- [ ] Ekran görüntüleri planı (App Store'da dikkat çekecek kalite)
- [ ] App Review test hesabı yaklaşımı

## Teknik
- [ ] Crash reporting kararı (MVP'de Sentry yok; karar `DECISIONS.md`)
- [ ] Production build testi (Android release + Codemagic iOS)
- [ ] Secret'ların depoda/YAML'da olmadığının doğrulanması
