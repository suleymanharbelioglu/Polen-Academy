import 'dart:io';

import 'package:flutter/services.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';
import 'package:polen_academy/data/user/source/user_firebase_service.dart';
import 'package:polen_academy/service_locator.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_flutter/errors.dart';

/// RevenueCat ile abonelik yönetimi ve VIP durumunun Firestore ile senkronizasyonu.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService _instance = RevenueCatService._();
  factory RevenueCatService() => _instance;

  bool _configured = false;

  /// Uygulama başında veya koç giriş yaptığında bir kez çağrılmalı.
  /// [appUserId] Firebase Auth UID (koç) – RevenueCat ile eşleşir.
  Future<void> configure(String appUserId) async {
    if (_configured) return;
    final apiKey = Platform.isIOS
        ? RevenueCatConfig.iosApiKey
        : RevenueCatConfig.androidApiKey;
    if (apiKey.isEmpty || apiKey.startsWith('YOUR_')) {
      return; // API key yoksa sessizce çık (geliştirme ortamı)
    }
    await Purchases.configure(
      PurchasesConfiguration(apiKey)..appUserID = appUserId,
    );
    _configured = true;
  }

  /// Mevcut offering ve paketleri getirir (aylık / yıllık).
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      return null;
    }
  }

  /// [package] satın alınır; başarılıysa Firestore'da koçun isVip = true yapılır.
  /// Hata mesajı döner veya null (başarılı).
  Future<String?> purchasePackage(Package package, String coachUid) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isActive = customerInfo.entitlements.all[RevenueCatConfig.entitlementId]?.isActive ?? false;
      if (isActive) {
        final updateResult = await sl<UserFirebaseService>().updateCoachVip(coachUid, true);
        updateResult.fold(
          (err) => null, // Firestore güncelleme hatası loglanabilir
          (_) => null,
        );
      }
      return null;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return null; // Kullanıcı iptal etti
      }
      return e.message ?? 'Satın alma başarısız.';
    } catch (e) {
      return e.toString();
    }
  }

  /// Mevcut kullanıcının VIP entitlement'ı aktif mi?
  Future<bool> isEntitlementActive() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[RevenueCatConfig.entitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Restore purchases (App Store / Play Store’dan eski satın almaları geri yükle).
  Future<String?> restorePurchases(String coachUid) async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive = customerInfo.entitlements.all[RevenueCatConfig.entitlementId]?.isActive ?? false;
      if (isActive) {
        await sl<UserFirebaseService>().updateCoachVip(coachUid, true);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
