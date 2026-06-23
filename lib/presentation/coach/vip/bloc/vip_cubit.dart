import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';
import 'package:polen_academy/data/revenuecat/revenuecat_service.dart';
import 'package:polen_academy/domain/subscription/entity/coach_subscription_status.dart';
import 'package:polen_academy/presentation/coach/vip/bloc/vip_state.dart';
import 'package:polen_academy/service_locator.dart';

class VipCubit extends Cubit<VipState> {
  VipCubit({int? initialSelectedStudents})
      : super(VipState(
          selectedStudents:
              initialSelectedStudents ?? RevenueCatConfig.studentTiers.first,
          isLoading: true,
        )) {
    loadPackages();
  }

  final RevenueCatService _revenueCat = sl<RevenueCatService>();

  Future<void> loadPackages() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final packages = await _revenueCat.getPackageOptions();
      emit(state.copyWith(
        isLoading: false,
        packages: packages,
        selectedStudents: packages.isNotEmpty
            ? packages.first.students
            : state.selectedStudents,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Planlar yüklenemedi. Lütfen tekrar deneyin.',
      ));
    }
  }

  void selectStudents(int students) {
    emit(state.copyWith(selectedStudents: students, clearError: true));
  }

  Future<CoachSubscriptionStatus?> purchaseMonthly() async {
    final option = state.monthlyOption;
    if (option == null) {
      emit(state.copyWith(errorMessage: 'Aylık plan bulunamadı.'));
      return null;
    }
    return _purchase(option);
  }

  Future<CoachSubscriptionStatus?> purchaseYearly() async {
    final option = state.yearlyOption;
    if (option == null) {
      emit(state.copyWith(errorMessage: 'Yıllık plan bulunamadı.'));
      return null;
    }
    return _purchase(option);
  }

  Future<CoachSubscriptionStatus?> restorePurchases() async {
    emit(state.copyWith(isPurchasing: true, clearError: true));
    try {
      final status = await _revenueCat.restorePurchases();
      emit(state.copyWith(isPurchasing: false));
      return status;
    } on PlatformException catch (e) {
      emit(state.copyWith(
        isPurchasing: false,
        errorMessage: e.message ?? 'Geri yükleme başarısız.',
      ));
      return null;
    } catch (_) {
      emit(state.copyWith(
        isPurchasing: false,
        errorMessage: 'Geri yükleme başarısız.',
      ));
      return null;
    }
  }

  Future<CoachSubscriptionStatus?> _purchase(SubscriptionPackageOption option) async {
    emit(state.copyWith(isPurchasing: true, clearError: true));
    try {
      final status = await _revenueCat.purchasePackage(option.package);
      emit(state.copyWith(isPurchasing: false));
      return status;
    } on PurchaseCancelledException {
      emit(state.copyWith(isPurchasing: false));
      return null;
    } on PlatformException catch (e) {
      emit(state.copyWith(
        isPurchasing: false,
        errorMessage: e.message ?? 'Satın alma başarısız.',
      ));
      return null;
    } catch (_) {
      emit(state.copyWith(
        isPurchasing: false,
        errorMessage: 'Satın alma başarısız. Lütfen tekrar deneyin.',
      ));
      return null;
    }
  }
}
