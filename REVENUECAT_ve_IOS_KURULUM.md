# RevenueCat Ödeme ve iOS Kurulumu

Bu dokümanda RevenueCat entegrasyonu ile **sizin yapmanız gereken** adımlar özetleniyor. Uygulama tarafında öğrenci kotasına göre katmanlı abonelik, VIP sayfası, Firestore senkronu ve sunucu tarafı limit kontrolü hazır.

---

## Abonelik modeli

| Durum | Öğrenci limiti |
|-------|----------------|
| Ücretsiz (abonelik yok) | **1 öğrenci** |
| `polen_coach_5_monthly` / `_yearly` | **5 öğrenci** |
| `polen_coach_10_monthly` / `_yearly` | **10 öğrenci** |
| `polen_coach_20_monthly` / `_yearly` | **20 öğrenci** |

- Sadece **koç** rolü ödeme yapabilir.
- Aylık ve yıllık planlar aynı **subscription group** içinde olmalı; böylece App Store / Play Store yükseltmede fark ücretini (proration) otomatik hesaplar.
- Koç daha yüksek kotaya geçtiğinde uygulama ilgili paketi satın alır; mağaza mevcut aboneliği yükseltir.

---

## 1. RevenueCat hesabı ve proje

1. [RevenueCat](https://app.revenuecat.com) üzerinden ücretsiz hesap açın.
2. Yeni bir **Project** oluşturun (örn. "Polen Academy").
3. **API Keys** bölümünden:
   - **iOS** uygulaması için **Public API Key**
   - **Android** uygulaması için **Public API Key**

---

## 2. Uygulama içinde API anahtarlarını girin

`lib/core/configs/revenuecat_config.dart` dosyasında placeholder değerleri değiştirin:

- `iosApiKey` → RevenueCat iOS Public API Key
- `androidApiKey` → RevenueCat Android Public API Key

Entitlement identifier: **`coach`** (dashboard ile aynı olmalı).

Öğrenci kotası seçenekleri kodda: `[5, 10, 20]` — değiştirmek için `studentTiers` listesini güncelleyin ve mağaza ürünlerini buna göre oluşturun.

---

## 3. App Store Connect ve Google Play ürünleri

Her kota × dönem için bir abonelik ürünü oluşturun. **Ürün ID formatı kodla uyumlu olmalı:**

```
polen_coach_5_monthly
polen_coach_5_yearly
polen_coach_10_monthly
polen_coach_10_yearly
polen_coach_20_monthly
polen_coach_20_yearly
```

### App Store Connect
1. **Subscription Group** oluşturun (tüm planlar aynı grupta).
2. Yukarıdaki 6 ürünü bu gruba ekleyin.
3. Aylık ve yıllık fiyatları belirleyin.

### Google Play Console
1. **Subscriptions** bölümünde aynı ürün ID'leriyle abonelikler oluşturun.
2. Tüm abonelikleri aynı **base plan / subscription group** altında tutun (yükseltme için).

---

## 4. RevenueCat dashboard yapılandırması

1. **Entitlements** → Identifier: `coach`
2. **Products** → App Store ve Play ürünlerini ekleyip mağazalarla eşleştirin; hepsini `coach` entitlement'ına bağlayın.
3. **Offerings** → `default` (veya yeni) offering oluşturup **Current** yapın.
4. Offering içine **6 package** ekleyin (Custom package identifier önerisi):

| Package ID | Store product |
|------------|---------------|
| `coach_5_monthly` | `polen_coach_5_monthly` |
| `coach_5_yearly` | `polen_coach_5_yearly` |
| `coach_10_monthly` | `polen_coach_10_monthly` |
| `coach_10_yearly` | `polen_coach_10_yearly` |
| `coach_20_monthly` | `polen_coach_20_monthly` |
| `coach_20_yearly` | `polen_coach_20_yearly` |

5. **Project Settings → Apps** → App Store Connect ve Google Play bağlantılarını tamamlayın.

RevenueCat dokümantasyonu: [RevenueCat Docs](https://docs.revenuecat.com).

---

## 5. iOS tarafı

1. `ios/Runner.xcworkspace` ile Xcode'da açın.
2. **Runner** target → **Signing & Capabilities** → **In-App Purchase** ekleyin.
3. `ios/Podfile` → `platform :ios, '15.0'` (mevcut).
4. Terminal: `cd ios && pod install`

---

## 6. Android tarafı

- `BILLING` izni `AndroidManifest.xml` içinde mevcut.
- Google Play Console'da abonelikleri test hesaplarıyla doğrulayın.

---

## 7. Firestore alanları (koç dokümanı)

Satın alma sonrası uygulama otomatik günceller:

```json
{
  "isVip": true,
  "studentLimit": 10,
  "subscriptionProductId": "polen_coach_10_monthly"
}
```

`createStudent` Cloud Function, `studentLimit` alanına göre sunucu tarafında da kontrol yapar.

---

## 8. Test

- **iOS Sandbox:** App Store Connect sandbox kullanıcısı ile test edin.
- **Android:** Play Console lisans test kullanıcıları ile test edin.
- Koç olarak giriş → **Menü** → plan kartı → öğrenci sayısı seç → aylık/yıllık satın al.
- Limit dolunca öğrenci eklerken yükseltme ekranı açılmalı.
- **Satın Alımları Geri Yükle** butonunu deneyin.

---

## 9. Özet checklist

| # | Görev |
|---|--------|
| 1 | RevenueCat proje + iOS/Android API key |
| 2 | `revenuecat_config.dart` anahtarları doldur |
| 3 | App Store + Play'de 6 abonelik ürünü (aynı subscription group) |
| 4 | RevenueCat'te `coach` entitlement + offering + 6 package |
| 5 | Xcode'da In-App Purchase capability |
| 6 | Cloud Function deploy (`firebase deploy --only functions`) |
| 7 | Sandbox / test ile satın alma, yükseltme ve geri yükleme testi |

---

## Kod yapısı (referans)

| Dosya | Görev |
|-------|--------|
| `lib/data/revenuecat/revenuecat_service.dart` | RevenueCat SDK |
| `lib/common/bloc/coach_subscription_cubit.dart` | Abonelik durumu |
| `lib/presentation/coach/vip/page/vip_page.dart` | Plan seçim ekranı |
| `lib/common/helper/subscription/add_student_subscription_gate.dart` | Öğrenci ekleme limiti |
| `functions/src/index.ts` → `createStudent` | Sunucu tarafı limit |
