import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class GetCurrentUserRoleUseCase implements UseCase<String?, void> {
  @override
  Future<String?> call({void params}) async {
    return sl<AuthRepository>().getCurrentUserRole();
  }
}
