import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';
import 'package:polen_academy/domain/subscription/entity/coach_subscription_status.dart';

class SubscriptionPackageOption {
  const SubscriptionPackageOption({
    required this.students,
    required this.isYearly,
    required this.package,
    required this.priceString,
    required this.pricePerMonthString,
    required this.pricePerStudentString,
    this.yearlyTotalString,
  });

  final int students;
  final bool isYearly;
  final Package package;
  final String priceString;
  final String pricePerMonthString;
  final String pricePerStudentString;
  final String? yearlyTotalString;
}

class RevenueCatService {
  bool _configured = false;

  Future<void> configure() async {
    if (_configured) return;
    if (!RevenueCatConfig.isConfigured) {
      debugPrint('[RevenueCat] API anahtarları yapılandırılmamış.');
      return;
    }
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(RevenueCatConfig.apiKey));
    _configured = true;
  }

  Future<void> logIn(String coachUid) async {
    if (!_configured) return;
    await Purchases.logIn(coachUid);
  }

  Future<void> logOut() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } catch (_) {}
  }

  Future<CoachSubscriptionStatus> getSubscriptionStatus() async {
    if (!_configured) return CoachSubscriptionStatus.initial;
    try {
      final info = await Purchases.getCustomerInfo();
      return _statusFromCustomerInfo(info);
    } catch (e) {
      debugPrint('[RevenueCat] getSubscriptionStatus hata: $e');
      return CoachSubscriptionStatus.initial;
    }
  }

  Future<List<SubscriptionPackageOption>> getPackageOptions() async {
    if (!_configured) return [];
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return [];

      final options = <SubscriptionPackageOption>[];
      for (final package in current.availablePackages) {
        final productId = package.storeProduct.identifier;
        final students = RevenueCatConfig.studentLimitFromProductId(productId);
        if (students == null || !RevenueCatConfig.studentTiers.contains(students)) {
          continue;
        }
        final isYearly = RevenueCatConfig.isYearlyProduct(productId);
        final product = package.storeProduct;
        final price = product.price;
        final priceString = product.priceString;

        final pricePerMonthString = isYearly
            ? _formatMonthlyFromYearly(product)
            : '$priceString /ay';

        final perStudent = price / students;
        final pricePerStudentString =
            '${perStudent.toStringAsFixed(2)} ${product.currencyCode}';

        options.add(
          SubscriptionPackageOption(
            students: students,
            isYearly: isYearly,
            package: package,
            priceString: priceString,
            pricePerMonthString: pricePerMonthString,
            pricePerStudentString: pricePerStudentString,
            yearlyTotalString: isYearly ? priceString : null,
          ),
        );
      }

      options.sort((a, b) {
        final tierCompare = a.students.compareTo(b.students);
        if (tierCompare != 0) return tierCompare;
        return a.isYearly ? 1 : -1;
      });
      return options;
    } catch (e) {
      debugPrint('[RevenueCat] getPackageOptions hata: $e');
      return [];
    }
  }

  String _formatMonthlyFromYearly(StoreProduct product) {
    final monthly = product.price / 12;
    return '${monthly.toStringAsFixed(2)} ${product.currencyCode} /ay';
  }

  Future<CoachSubscriptionStatus> purchasePackage(Package package) async {
    if (!_configured) {
      throw PlatformException(
        code: 'NOT_CONFIGURED',
        message: 'RevenueCat yapılandırılmamış. API anahtarlarını kontrol edin.',
      );
    }
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _statusFromCustomerInfo(result.customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw PurchaseCancelledException();
      }
      rethrow;
    }
  }

  Future<CoachSubscriptionStatus> restorePurchases() async {
    if (!_configured) {
      throw PlatformException(
        code: 'NOT_CONFIGURED',
        message: 'RevenueCat yapılandırılmamış.',
      );
    }
    final info = await Purchases.restorePurchases();
    return _statusFromCustomerInfo(info);
  }

  CoachSubscriptionStatus _statusFromCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[RevenueCatConfig.entitlementId];
    if (entitlement?.isActive != true) {
      return CoachSubscriptionStatus.initial;
    }

    final productId = entitlement!.productIdentifier;
    final limit = RevenueCatConfig.studentLimitFromProductId(productId);
    return CoachSubscriptionStatus(
      studentLimit: limit ?? RevenueCatConfig.studentTiers.first,
      activeProductId: productId,
    );
  }
}

class PurchaseCancelledException implements Exception {}
