import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetUnreadNotificationCountUseCase implements UseCase<Either<String, int>, String> {
  @override
  Future<Either<String, int>> call({String? params}) async {
    if (params == null || params.isEmpty) return const Right(0);
    return sl<NotificationRepository>().getUnreadCount(params);
  }
}
