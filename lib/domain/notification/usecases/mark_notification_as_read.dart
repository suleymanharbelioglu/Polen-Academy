import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

class MarkNotificationAsReadUseCase implements UseCase<Either<String, void>, String> {
  @override
  Future<Either<String, void>> call({String? params}) async {
    if (params == null || params.isEmpty) return const Right(null);
    return sl<NotificationRepository>().markAsRead(params!);
  }
}
