import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

class CreateNotificationsUseCase implements UseCase<Either<String, void>, List<NotificationEntity>> {
  @override
  Future<Either<String, void>> call({List<NotificationEntity>? params}) async {
    if (params == null || params.isEmpty) return const Right(null);
    return sl<NotificationRepository>().createMany(params);
  }
}
