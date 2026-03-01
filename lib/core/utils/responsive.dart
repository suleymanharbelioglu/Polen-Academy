/// Responsive tasarım için flutter_screenutil kullanımı.
///
/// Tasarım boyutu: lib/core/configs/screen_design_size.dart içinde sabit (width x height).
/// Widget build içinde:
/// - [sayi.w]  → genişliğe göre ölçeklenen pixel (örn. 16.w)
/// - [sayi.h]  → yüksekliğe göre ölçeklenen pixel (örn. 24.h)
/// - [sayi.sp] → font boyutu (örn. 14.sp)
/// - [sayi.r]  → yarıçap / border radius (örn. 12.r)
///
/// Örnek:
///   SizedBox(height: 24.h)
///   padding: EdgeInsets.all(16.w)
///   TextStyle(fontSize: 14.sp)
export 'package:flutter_screenutil/flutter_screenutil.dart';
