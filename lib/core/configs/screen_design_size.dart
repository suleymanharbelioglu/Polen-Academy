import 'dart:ui';

/// ScreenUtil design size: Tasarımı yaptığınız cihazın sabit ölçüleri.
/// Bu değerleri kullandığınız cihazın ekran boyutuna göre güncelleyin.
/// (Uygulama açılırken konsolda "Cihaz boyutları" yazdırılıyorsa o değerleri buraya yapıştırabilirsiniz.)
class ScreenDesignSize {
  ScreenDesignSize._();

  /// Tasarım genişliği (logical pixels)
  static const double width = 392.7;

  /// Tasarım yüksekliği (logical pixels)
  static const double height = 825.5;

  static Size get size => const Size(width, height);
}
