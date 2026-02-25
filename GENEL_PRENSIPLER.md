# Kodlama Kuralları (Yapay Zekâ İçin)

Bu projede kod yazarken veya değiştirirken **aşağıdaki kurallara uy**. Hepsi zorunludur; istisna yapma.

---

## 1. Mimari

- **Clean Architecture** kullan: **domain** (iş kuralları), **data** (veri kaynağı), **presentation** (UI). Domain hiçbir katmana bağımlı olmasın; data ve presentation domain’e bağımlı olsun.
- Veri erişimi **her zaman** domain’deki **soyut repository** üzerinden olsun; implementasyonu data katmanında yaz.

---

## 2. Soyutlama ve UI

**Soyutlama**
- **Repository**: Abstract sınıf domain’de; implementasyon data’da. UI ve Cubit veri kaynağını (Firestore, API) bilmesin; sadece repository metotlarını çağırsın.
- **UseCase**: Her iş birimi için tek UseCase sınıfı. Cubit sadece UseCase çağırsın; iş kuralı ve veri akışı domain/data’da kalsın.
- **Source**: Firebase/API detayı sadece data katmanında olsun; domain ve presentation buna bağımlı olmasın.

**UI’da logic olmasın**
- UI **sadece göstersin** (state veya parametre) ve **tetiklesin** (`context.read<XCubit>().metod()` veya callback). İş kuralı, hesaplama, filtreleme, veri dönüşümü UI’da **yazma**; bunları Cubit veya domain/data’da yaz.
- Sayfa ve widget’ları **mümkünse StatelessWidget** yap. Build içi sadece state’i okuyup widget ağacı kursun; karmaşık if/hesap koyma.

**Değişkenler Cubit’te olsun**
- Ekrana ait tüm state (liste, loading, error, seçimler, form alanları vb.) **Cubit state** içinde olsun. UI `BlocBuilder` ile okusun; değiştirmek için Cubit metodunu çağırsın.
- UI’da **mümkün olduğunca lokal state (setState, member variable) kullanma**. İstisna: sadece görsel/geçici (expansion açık/kapalı, overlay bayrağı) veya Flutter zorunluluğu (TextEditingController, GlobalKey<FormState>) — bunları da en aza indir.
- Form verisini de mümkünse Cubit state’te tut; submit’te Cubit’e iletilip orada güncellensin.

---

## 3. Klasör ve Dosyalama

**Konu bazlı (topic-first)** kullan. Önce konu/feature, altında katmana uygun klasörler.

| Katman        | Yapı | Alt klasörler |
|---------------|------|----------------|
| Domain        | `domain/<konu>/` | `entity/`, `repository/`, `usecases/` |
| Data          | `data/<konu>/`   | `model/`, `source/`, `repository/` |
| Presentation  | `presentation/<feature>/` | `page/`, `widget/`, `bloc/` |

- Aynı konu adını domain ve data’da kullan (auth, user, session, homework vb.).
- Her feature altında `page/`, `widget/`, `bloc/` (Cubit ve state dosyaları `bloc/` içinde).

---

## 4. Core

- Proje çapında, tek feature’a ait olmayan altyapı ve sabitler **core**’da olsun.
- UseCase taban sınıfı: `core/usecase/usecase.dart` — `abstract class UseCase<Type, Params>`, `Future<Type> call({Params? params})`. Tüm UseCase’ler bunu implement etsin.
- Tema: `core/configs/theme/` — `app_colors.dart`, `app_theme.dart`. Sabitler: `app_urls.dart` veya `app_constants.dart` tek dosyada.

---

## 5. Common

- Birden fazla feature’da kullanılan widget, helper, cubit **common**’da olsun. Tek ekrana özel olan presentation/feature’da kalsın.
- Navigator helper: `common/helper/navigator/` (push, pushReplacement, pushAndRemove). Diğer helper’lar: `common/helper/<konu>/`.
- Ortak widget’lar (loading_overlay, ortak dialog’lar): `common/widget/`. Uygulama çapında tek akış cubit’leri (örn. logout): `common/bloc/`.
- **Sadece gerçekten birden fazla yerde kullanılanları** common’a koy; “belki lazım olur” diye ekleme.

---

## 6. Domain Katmanı

- **Entity**: Saf Dart; framework veya `fromMap` yok. Gerekirse `copyWith`. Sabit seçenekler için enum (entity dosyasında veya domain’de).
- **Repository**: Abstract class. Metotlar `Either<String, T>` (veya `Future<T>`); hata için Either kullan.
- **UseCase**: Tek sorumluluk. `UseCase<Type, Params>` implement et; `call({Params? params})`. Param yoksa `void`. Birden fazla parametre için aynı dosyada **XxxParams** sınıfı (const, required). UseCase **sadece** `sl<Repository>()` ile repository çağırsın; başka iş yapmasın.

---

## 7. Data Katmanı

- **Model**: `fromMap` / `toMap` (veya fromJson/toJson). Null/eksik için `?? ''`, `?? []`, `?? 0`. Tarih için private `_parse` (Timestamp/DateTime/String). Extension: **ModelX** → `toEntity()`, **EntityX** → `toModel()` (aynı model dosyasında).
- **Source**: Abstract + Impl. Collection/endpoint adı `static const String _collection = 'Xxx'`. Tüm async çağrıyı **try/catch** ile sar; hata → **Left(kullanıcıya anlamlı mesaj)**, başarı → **Right(T)**. Boş/geçersiz girişte erken return: `if (ids.isEmpty) return const Right([]);`.
- **Firestore tarih**: Sorguda normalize et (başlangıç gün başı, bitiş 23:59:59). Okuma: Timestamp → toDate/toIso8601String veya parse; yazma: Timestamp.fromDate. Gerekirse _docToMap, _modelToFirestore private yardımcıları kullan.
- **RepositoryImpl**: Source’u çağırsın; Model → Entity dönüşümü yapsın; Either’ı olduğu gibi iletsin.

---

## 8. Bağımlılık Enjeksiyonu

- **GetIt** kullan. Tüm kayıtlar tek dosyada (service_locator / injection). Alias: `final sl = GetIt.instance`; erişim `sl<T>()`.
- Kayıt sırası: **Services** → **Repositories** → **Use cases** (domain gruplarına göre). Singleton.
- UI’da Cubit: sayfa/ekran seviyesinde `BlocProvider(create: (_) => XCubit(...))`. Alt sayfaya cubit taşımak için `BlocProvider.value(value: context.read<XCubit>(), child: ...)`.

---

## 9. State ve Hata Yönetimi

- **Sadece Cubit** kullan (Bloc değil). State: Equatable (auth/form/dialog) veya copyWith’li tek class (liste + loading + error). Aynı feature içinde tutarlı stil kullan.
- **copyWith**: Nullable alanı temizleyebilmek için parametreyi olduğu gibi ata: `errorMessage: errorMessage` (böylece `copyWith(errorMessage: null)` gerçekten null yapar).
- Hata: **dartz** `Either<String, T>` — Left = mesaj, Right = sonuç. Cubit `sl<>()` ile UseCase/Repository çağırsın; `fold` ile state güncellesin veya SnackBar göstersin.
- Load/action başında **guard clause** koy: `if (id.isEmpty) return;` — gereksiz çağrı yapma.
- Tek seferlik tetikleyici (navigate, dialog) için küçük cubit kullan: emit(Requested) → BlocListener işi yapsın → reset().

---

## 10. Navigasyon

- **MaterialPageRoute** + push / pushReplacement / pushAndRemoveUntil kullan. Named route zorunlu değil.
- Ortak helper kullan: AppNavigator.push, pushAndRemove vb.; içeride MaterialPageRoute(builder: ...).
- Yeni sayfada Cubit gerekiyorsa: push içinde BlocProvider(create: ...) veya BlocProvider.value ile mevcut cubit ver.

---

## 11. Widget'lar

- **Olabildiğince StatelessWidget** yaz. StatefulWidget yalnızca zorunlu (controller, form key) veya salt görsel/geçici durum (expansion, overlay bayrağı) için kullan; mümkünse en dar kapsamda tut.
- **Widget içinde logic yazma**: Widget sadece **göstersin** (parametre veya state) ve **tetiklesin** (callback veya `context.read<XCubit>()`). Hesaplama, filtreleme, karar, veri dönüşümü widget’ta olmasın; veri hazır gelsin. Build mümkünse sadece widget ağacı; karmaşık if/for/hesap koyma.
- **Tertemiz kod**: Sade, okunabilir, tek sorumluluk. Gereksiz değişken, tekrar ve karmaşıklık ekleme. İsimlendirme net; format tutarlı. Widget büyüyorsa parçalara böl.

---

## 12. Tema ve Stil

- Renkler ve ThemeData **core/configs/theme/** altında tek yerde (app_colors, app_theme) olsun. Ortak bileşenler tema ile uyumlu; tekrar eden stili ortak widget’a taşı.

---

## 13. İsimlendirme

- **Dosya**: snake_case. **Sınıf**: PascalCase. Cubit/State için tutarlı prefix (HomeCubit, HomeState).
- **Domain/Data**: XxxEntity, XxxModel, XxxRepository / XxxRepositoryImpl, XxxUseCase, XxxParams, XxxFirebaseService + Impl. Extension: XxxModelX, XxxEntityX.
- Firebase çağrıları sadece data katmanında; firestore.indexes.json projede tutulsun.

---

## 14. Genel Kurallar

- **State ve değişken Cubit’te**: UI’da olabildiğince az değişken ve logic; ekran state’i Cubit’te, UI sadece göstersin ve aksiyonu Cubit’e iletsin.
- **Tertemiz kod**: Sade, okunabilir, tek sorumluluk. Gereksiz değişken ve tekrar ekleme; isimlendirme net, format tutarlı. Karmaşıklaşan parçayı böl.
- Async sonrası mutlaka kontrol et: `if (!isClosed) emit(...)` veya `if (!mounted) return`.
- Form/dialog’ta BlocConsumer kullan: listener’da navigate/SnackBar, builder’da UI.
- Global state kullanma; paylaşılacak state için küçük cubit kullan (örn. seçili öğe).
- **Import sırası**: Önce paketler (flutter, flutter_bloc, dartz…), sonra proje (core, data/domain, presentation); service_locator en sonda. Okunabilirlik öncelikli.
- Boş/hata ekranı: Liste boş veya sadece loading → placeholder veya SizedBox.shrink; hata + boş liste → mesaj + “Tekrar dene” benzeri aksiyon.
- Yorum: Türkçe veya İngilizce tutarlı kullan; iş kuralı ve “neden” için kısa açıklama yaz.

---

Bu kurallara uyarak kod yaz ve değiştir. İstisna yapma; belirsizlik olursa bu dokümana göre karar ver.
