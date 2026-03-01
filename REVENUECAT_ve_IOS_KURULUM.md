# RevenueCat Ödeme ve iOS Kurulumu

Bu dokümanda RevenueCat entegrasyonu ile **sizin yapmanız gereken** adımlar özetleniyor. Uygulama tarafında ödeme akışı, VIP sayfası ve Firestore senkronu hazır; aşağıdakileri tamamlamanız yeterli.

---

## 1. RevenueCat hesabı ve proje

1. [RevenueCat](https://app.revenuecat.com) üzerinden ücretsiz hesap açın.
2. Yeni bir **Project** oluşturun (örn. "Polen Academy").
3. **API Keys** bölümünden:
   - **iOS** uygulaması için bir **Public API Key** (App Store Connect ile bağlı) alın.
   - **Android** uygulaması için bir **Public API Key** (Google Play Console ile bağlı) alın.

---

## 2. Uygulama içinde API anahtarlarını girin

`lib/core/configs/revenuecat_config.dart` dosyasında placeholder değerleri kendi anahtarlarınızla değiştirin:

- `iosApiKey` → RevenueCat iOS Public API Key
- `androidApiKey` → RevenueCat Android Public API Key

Entitlement identifier olarak `vip` kullanılıyor; RevenueCat dashboard’da da aynı isimle entitlement oluşturacaksınız.

---

## 3. RevenueCat dashboard’da yapılandırma

1. **Entitlements**
   - **Entitlements** → **New**
   - Identifier: `vip` (kodla aynı olmalı)
   - İsterseniz açıklama ekleyin.

2. **Products (App Store Connect & Google Play)**
   - **App Store Connect** ve **Google Play Console** içinde uygulamanız için abonelik ürünleri oluşturun (aylık ve yıllık).
   - Ürün ID’lerini not alın (örn. `polen_vip_monthly`, `polen_vip_annual`).

3. **RevenueCat’te Products**
   - RevenueCat’te **Products** bölümünde bu ürünleri ekleyin ve ilgili store ile eşleştirin.

4. **Offerings**
   - **Offerings** → **New** (veya mevcut **default** offering’i kullanın).
   - Bu offering’i **Current** yapın.
   - Offering içinde **Packages** ekleyin:
     - Aylık: **Monthly** package type, App Store / Play’deki aylık product ID.
     - Yıllık: **Annual** package type, App Store / Play’deki yıllık product ID.

5. **App Store Connect / Google Play bağlantısı**
   - RevenueCat’te **Project Settings** → **Apps** kısmından:
     - iOS app’i App Store Connect ile (Shared Secret / In-App Purchase key vb. gerekirse) bağlayın.
     - Android app’i Google Play ile (Service account JSON vb.) bağlayın.

RevenueCat dokümantasyonu: [RevenueCat Docs](https://docs.revenuecat.com).

---

## 4. iOS tarafı (iPhone uygulaması)

### 4.1 Xcode

1. Projeyi Xcode ile açın: `ios/Runner.xcworkspace` (`.xcworkspace` kullanın, `.xcodeproj` değil).
2. Sol taraftan **Runner** projesini ve **Runner** target’ını seçin.
3. **Signing & Capabilities** sekmesinde **+ Capability** ile **In-App Purchase** ekleyin.
4. **Podfile** (proje kökündeki `ios/Podfile`):
   - Minimum iOS sürümü **13.0** veya üzeri olmalı (RevenueCat Flutter SDK gereksinimi):
     ```ruby
     platform :ios, '13.0'
     ```
   - Değiştirdiyseniz terminalde: `cd ios && pod install`.

### 4.2 App Store Connect

1. App Store Connect’te uygulamanızı oluşturun / seçin.
2. **In-App Purchases** bölümünde **Subscription** ürünleri oluşturun (aylık ve yıllık).
3. Subscription Group oluşturup bu ürünleri bu gruba ekleyin.
4. RevenueCat’te bu product ID’leri ilgili offering / package’lara bağlayın (yukarıdaki adım 3–4).

---

## 5. Android tarafı

- **BILLING** izni projede eklendi (`AndroidManifest.xml`).
- **Launch mode** zaten `singleTop` (ödeme doğrulama ekranları için uygun).
- Google Play Console’da **In-app products** veya **Subscriptions** tanımlayıp RevenueCat’te bu product ID’leri kullanın.

---

## 6. Test

- **Sandbox (iOS):** App Store Connect’te Sandbox test kullanıcısı oluşturup cihazda bu hesapla giriş yaparak satın alma testi yapın.
- **Test (Android):** Google Play Console’da test hesapları ekleyip aynı şekilde test edin.
- Uygulamada koç olarak giriş yapıp **Menü** → **VIP** kartına tıklayın; aylık/yıllık planları görüp satın almayı ve **Geri yükle** butonunu deneyin.

---

## 7. Özet: Sizin yapacaklarınız

| Adım | Açıklama |
|------|----------|
| 1 | RevenueCat hesabı açıp proje ve iOS/Android API key’lerini almak |
| 2 | `revenuecat_config.dart` içinde `iosApiKey` ve `androidApiKey` değerlerini doldurmak |
| 3 | RevenueCat’te `vip` entitlement, products ve default offering (aylık/yıllık package) oluşturmak |
| 4 | App Store Connect’te abonelik ürünleri, Google Play’de subscription ürünleri tanımlayıp RevenueCat’e bağlamak |
| 5 | Xcode’da Runner target’a **In-App Purchase** capability eklemek |
| 6 | `ios/Podfile`’da `platform :ios, '13.0'` (veya üzeri) olduğundan emin olmak, gerekirse `pod install` |
| 7 | Sandbox / test hesaplarıyla satın alma ve “Geri yükle” akışını test etmek |

Kod tarafında VIP satın alma, Firestore’da `isVip` güncellemesi ve VIP sayfası hazır; yukarıdaki yapılandırmaları tamamladığınızda hem Android hem iPhone’da ödeme çalışır.
