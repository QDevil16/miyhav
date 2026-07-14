# CODEMAGIC_IOS_PLAN — iOS Cloud Build ve Yayın Planı

## Neden Codemagic
Proje sahibi Windows kullanıyor; Mac/Xcode yok ve istenmeyecek. iOS süreci:
**Windows geliştirme → GitHub → Codemagic cloud macOS build → TestFlight →
App Store Connect.** Yerel derleme yok.

## codemagic.yaml (ilgili yayın görevinde oluşturulur)
Adımlar:
- Flutter bağımlılıkları
- `flutter analyze`
- `flutter test`
- Android build (APK/AAB)
- iOS build (macOS runner)
- **Automatic iOS code signing** (App Store Connect API key ile)
- TestFlight upload
- App Store Connect upload
- Artifact toplama, build cache, environment variable groups, secure secrets

Gizli bilgiler YAML'a **yazılmaz**; Codemagic environment variable group / secure
env üzerinden verilir.

## Gerekli Apple Değerleri (uydurulmaz — hesap sahibi sağlar)
App Store Connect API key (.p8), Issuer ID, Key ID, Bundle ID. Bunlar Codemagic
secret olarak girilir; depoya girmez.

## Manuel İşlemler (ilgili görev geldiğinde, basit Türkçe)
GitHub ↔ Codemagic bağlama, Apple Developer bağlama, App Store Connect API key
oluşturma/yükleme, ilk build başlatma, TestFlight doğrulama, App Store gönderimi.
Her adım hangi site/menü/buton/değer olduğu belirtilerek anlatılır.

## Kural
Gizli Apple bilgileri GitHub'a yazılmaz. Kullanıcı açıkça izin vermeden mağazaya
production yayın yapılmaz.
