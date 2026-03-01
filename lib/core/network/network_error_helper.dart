/// Ağ / sunucu hatalarını kullanıcıya gösterilecek Türkçe mesaja çevirir.
class NetworkErrorHelper {
  NetworkErrorHelper._();

  static const String _noConnectionMessage =
      'İnternet bağlantınızı kontrol edin.';
  static const String _timeoutMessage =
      'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
  static const String _genericNetworkMessage =
      'Bir bağlantı hatası oluştu. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  /// Hata metnini analiz eder; ağ/bağlantı hatası ise anlaşılır Türkçe mesaj döner.
  static String getUserFriendlyMessage(String? error) {
    if (error == null || error.isEmpty) return _genericNetworkMessage;
    final lower = error.toLowerCase();
    if (_isNoConnection(lower)) return _noConnectionMessage;
    if (_isTimeout(lower)) return _timeoutMessage;
    if (_isNetworkRelated(lower)) return _genericNetworkMessage;
    return error;
  }

  static bool _isNoConnection(String lower) {
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('network is unreachable') ||
        lower.contains('no internet') ||
        lower.contains('connection reset') ||
        lower.contains('connection timed out');
  }

  static bool _isTimeout(String lower) {
    return lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('deadline exceeded');
  }

  static bool _isNetworkRelated(String lower) {
    return lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('unable to resolve host') ||
        lower.contains('ioexception') ||
        lower.contains('handshake') ||
        lower.contains('certificate') ||
        lower.contains('connection closed');
  }
}
