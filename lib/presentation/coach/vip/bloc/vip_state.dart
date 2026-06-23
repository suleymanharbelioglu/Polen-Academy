import 'package:equatable/equatable.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';
import 'package:polen_academy/data/revenuecat/revenuecat_service.dart';

class VipState extends Equatable {
  const VipState({
    this.isLoading = true,
    this.isPurchasing = false,
    this.selectedStudents = 5,
    this.packages = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final bool isPurchasing;
  final int selectedStudents;
  final List<SubscriptionPackageOption> packages;
  final String? errorMessage;

  SubscriptionPackageOption? get monthlyOption => _optionFor(isYearly: false);

  SubscriptionPackageOption? get yearlyOption => _optionFor(isYearly: true);

  SubscriptionPackageOption? _optionFor({required bool isYearly}) {
    for (final option in packages) {
      if (option.students == selectedStudents && option.isYearly == isYearly) {
        return option;
      }
    }
    return null;
  }

  List<int> get availableTiers {
    final tiers = packages.map((p) => p.students).toSet().toList()..sort();
    if (tiers.isNotEmpty) return tiers;
    return RevenueCatConfig.studentTiers;
  }

  VipState copyWith({
    bool? isLoading,
    bool? isPurchasing,
    int? selectedStudents,
    List<SubscriptionPackageOption>? packages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VipState(
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      selectedStudents: selectedStudents ?? this.selectedStudents,
      packages: packages ?? this.packages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isPurchasing,
        selectedStudents,
        packages,
        errorMessage,
      ];
}
