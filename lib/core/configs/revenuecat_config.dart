/// RevenueCat API anahtarları.
/// Dashboard: https://app.revenuecat.com -> Project -> API Keys
/// iOS ve Android için ayrı public API key kullanın.
class RevenueCatConfig {
  RevenueCatConfig._();

  /// iOS uygulaması için RevenueCat Public API Key (App Store Connect ile bağlı)
  static const String iosApiKey = 'test_ZMmtYBAAeBqpvrZFPRpCGiEhCPf';

  /// Android uygulaması için RevenueCat Public API Key (Google Play Console ile bağlı)
  static const String androidApiKey = 'test_ZMmtYBAAeBqpvrZFPRpCGiEhCPf';

  /// Entitlement identifier – RevenueCat dashboard'da oluşturduğunuz (örn. "vip")
  static const String entitlementId = 'vip';

  /// Varsayılan offering identifier (RevenueCat'te "Current" olarak işaretlediğiniz offering)
  static const String defaultOfferingId = 'default';
}
