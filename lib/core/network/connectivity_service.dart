import 'package:connectivity_plus/connectivity_plus.dart';

/// İnternet bağlantı durumunu kontrol eder ve dinler.
/// Not: connectivity_plus sadece ağ bağlantısını (WiFi/veri) gösterir, gerçek internet erişimini garanti etmez.
class ConnectivityService {
  ConnectivityService._();
  static final Connectivity _connectivity = Connectivity();

  /// Şu an ağa bağlı mı (WiFi veya mobil veri).
  static Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  /// Bağlantı durumu değiştiğinde tetiklenir.
  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  static bool _hasConnection(List<ConnectivityResult> result) {
    if (result.isEmpty) return false;
    return result.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  /// Tek bir result listesi için (onConnectivityChanged tek değer verebilir).
  static bool hasConnectionFromResult(List<ConnectivityResult> result) =>
      _hasConnection(result);
}
