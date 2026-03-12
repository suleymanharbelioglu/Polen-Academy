import 'package:url_launcher/url_launcher.dart';

/// Ödev linkleri: scheme yoksa https ekler; Android 11+ ve tüm cihazlarda açılması için.
class LinkLauncherHelper {
  LinkLauncherHelper._();

  /// "www.example.com" → "https://www.example.com"
  static String normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  /// Linki tarayıcıda açar. canLaunchUrl false dönse bile dener (Android 11+ uyumu).
  static Future<bool> launchHomeworkLink(String url) async {
    final normalized = normalizeUrl(url);
    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
