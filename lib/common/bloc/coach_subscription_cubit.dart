import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/subscription/student_limit_helper.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';
import 'package:polen_academy/data/revenuecat/revenuecat_service.dart';
import 'package:polen_academy/domain/subscription/entity/coach_subscription_status.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

class CoachSubscriptionCubit extends Cubit<CoachSubscriptionStatus> {
  CoachSubscriptionCubit() : super(CoachSubscriptionStatus.initial);

  final RevenueCatService _revenueCat = sl<RevenueCatService>();

  /// Koç girişinde RevenueCat ve Firestore'dan abonelik durumunu yükler.
  Future<void> initializeForCoach(String coachUid) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _revenueCat.configure();
      await _revenueCat.logIn(coachUid);

      final coachResult = await sl<UserRepository>().getCoachByUid(coachUid);
      int firestoreLimit = RevenueCatConfig.freeStudentLimit;
      coachResult.fold((_) {}, (coach) {
        if (coach != null) {
          firestoreLimit = StudentLimitHelper.effectiveLimit(
            storedLimit: coach.studentLimit,
            isVip: coach.isVip,
          );
        }
      });

      if (RevenueCatConfig.isConfigured) {
        final rcStatus = await _revenueCat.getSubscriptionStatus();
        if (rcStatus.isSubscribed) {
          emit(rcStatus.copyWith(isLoading: false));
          await _syncToFirestore(coachUid, rcStatus);
          return;
        }
      }

      emit(
        CoachSubscriptionStatus(
          studentLimit: firestoreLimit,
          isLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('[CoachSubscription] initialize hata: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> syncFromRevenueCat(String coachUid) async {
    if (!RevenueCatConfig.isConfigured) return;
    emit(state.copyWith(isLoading: true));
    try {
      final status = await _revenueCat.getSubscriptionStatus();
      emit(status.copyWith(isLoading: false));
      if (status.isSubscribed) {
        await _syncToFirestore(coachUid, status);
      }
    } catch (e) {
      debugPrint('[CoachSubscription] sync hata: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> applyPurchaseResult(
    String coachUid,
    CoachSubscriptionStatus status,
  ) async {
    emit(status.copyWith(isLoading: false));
    await _syncToFirestore(coachUid, status);
  }

  void reset() => emit(CoachSubscriptionStatus.initial);

  Future<void> _syncToFirestore(
    String coachUid,
    CoachSubscriptionStatus status,
  ) async {
    await sl<UserRepository>().updateCoachSubscription(
      coachUid: coachUid,
      studentLimit: status.studentLimit,
      isVip: status.isSubscribed,
      subscriptionProductId: status.activeProductId,
    );
  }
}
