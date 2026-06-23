import 'dart:io';

/// RevenueCat ve mağaza ürün yapılandırması.
///
/// Dashboard'da her öğrenci kotası için aylık/yıllık abonelik ürünü oluşturun.
/// Ürün ID formatı: `polen_coach_{öğrenciSayısı}_monthly` / `_yearly`
/// Örnek: polen_coach_5_monthly, polen_coach_10_yearly
class RevenueCatConfig {
  RevenueCatConfig._();

  static const iosApiKey = 'appl_zScECqRtPJFgwZkIQiKfmBoGjQC';
  static const androidApiKey = 'goog_DmZMUOFQmvLUkhMoxLnAKcpekJc';

  /// RevenueCat entitlement identifier — dashboard ile aynı olmalı.
  static const entitlementId = 'coach';

  /// Ücretsiz planda eklenebilecek maksimum öğrenci sayısı.
  static const freeStudentLimit = 1;

  /// Satın alınabilir öğrenci kotası seçenekleri.
  static const studentTiers = [5, 10, 20];

  /// Yıllık planda gösterilen indirim yüzdesi (UI).
  static const yearlyDiscountPercent = 20;

  static String get apiKey => Platform.isIOS ? iosApiKey : androidApiKey;

  static String monthlyProductId(int students) => 'polen_coach_${students}_monthly';

  static String yearlyProductId(int students) => 'polen_coach_${students}_yearly';

  static bool get isConfigured => !apiKey.contains('REPLACE_WITH_YOUR');

  /// Mağaza ürün ID'sinden öğrenci kotasını çıkarır.
  static int? studentLimitFromProductId(String? productId) {
    if (productId == null || productId.isEmpty) return null;
    final match = RegExp(r'polen_coach_(\d+)_(monthly|yearly)').firstMatch(productId);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static bool isYearlyProduct(String? productId) =>
      productId != null && productId.endsWith('_yearly');
}
