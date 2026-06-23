import 'package:equatable/equatable.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';

class CoachSubscriptionStatus extends Equatable {
  const CoachSubscriptionStatus({
    required this.studentLimit,
    this.activeProductId,
    this.isLoading = false,
  });

  final int studentLimit;
  final String? activeProductId;
  final bool isLoading;

  bool get isSubscribed => studentLimit > RevenueCatConfig.freeStudentLimit;

  bool get isPremium => isSubscribed;

  static const initial = CoachSubscriptionStatus(
    studentLimit: RevenueCatConfig.freeStudentLimit,
  );

  CoachSubscriptionStatus copyWith({
    int? studentLimit,
    String? activeProductId,
    bool? isLoading,
    bool clearProductId = false,
  }) {
    return CoachSubscriptionStatus(
      studentLimit: studentLimit ?? this.studentLimit,
      activeProductId: clearProductId ? null : (activeProductId ?? this.activeProductId),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [studentLimit, activeProductId, isLoading];
}
