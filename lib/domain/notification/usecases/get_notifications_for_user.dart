import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetNotificationsForUserParams {
  final String userId;
  final int limit;

  const GetNotificationsForUserParams({required this.userId, this.limit = 50});
}

class GetNotificationsForUserUseCase
    implements UseCase<Either<String, List<NotificationEntity>>, GetNotificationsForUserParams> {
  @override
  Future<Either<String, List<NotificationEntity>>> call({GetNotificationsForUserParams? params}) async {
    if (params == null) return const Left('Kullanıcı gerekli');
    return sl<NotificationRepository>().getForUser(params.userId, limit: params.limit);
  }
}
