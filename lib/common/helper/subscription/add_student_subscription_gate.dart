import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/coach_subscription_cubit.dart';
import 'package:polen_academy/common/helper/subscription/student_limit_helper.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/presentation/coach/vip/page/vip_page.dart';
import 'package:polen_academy/service_locator.dart';

/// Öğrenci ekleme öncesi abonelik kotası kontrolü.
class AddStudentSubscriptionGate {
  AddStudentSubscriptionGate._();

  static Future<bool> ensureCanAddStudent(
    BuildContext context, {
    required int currentStudentCount,
  }) async {
    final subscription = context.read<CoachSubscriptionCubit>().state;
    if (StudentLimitHelper.canAddStudent(
      currentStudentCount: currentStudentCount,
      studentLimit: subscription.studentLimit,
    )) {
      return true;
    }

    final shouldOpenVip = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Plan Yükseltme Gerekli'),
        content: Text(
          '${StudentLimitHelper.limitMessage(subscription.studentLimit)} '
          'Daha fazla öğrenci eklemek için planınızı yükseltin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryCoach),
            child: const Text('Planı Yükselt'),
          ),
        ],
      ),
    );

    if (shouldOpenVip != true || !context.mounted) return false;

    final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
    final activated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VipPage(
          suggestedStudents: _suggestedTier(
            currentLimit: subscription.studentLimit,
            currentCount: currentStudentCount,
          ),
        ),
      ),
    );

    if (activated == true && coachUid != null && context.mounted) {
      await context.read<CoachSubscriptionCubit>().syncFromRevenueCat(coachUid);
    }

    if (!context.mounted) return false;
    final updatedLimit = context.read<CoachSubscriptionCubit>().state.studentLimit;
    return StudentLimitHelper.canAddStudent(
      currentStudentCount: currentStudentCount,
      studentLimit: updatedLimit,
    );
  }

  static int? _suggestedTier({
    required int currentLimit,
    required int currentCount,
  }) {
    final needed = currentCount + 1;
    for (final tier in RevenueCatConfig.studentTiers) {
      if (tier >= needed && tier > currentLimit) return tier;
    }
    return RevenueCatConfig.studentTiers.last;
  }
}
