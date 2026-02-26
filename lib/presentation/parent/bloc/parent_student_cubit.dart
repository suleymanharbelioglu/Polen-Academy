import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_student_by_parent_id.dart';
import 'package:polen_academy/service_locator.dart';

/// Veli giriş yaptığında bağlı öğrenciyi yükler. Sayfalar [state] ile öğrenci bilgisine erişir.
class ParentStudentCubit extends Cubit<StudentEntity?> {
  ParentStudentCubit({required String parentUid}) : super(null) {
    _load(parentUid);
  }

  Future<void> _load(String parentUid) async {
    if (parentUid.isEmpty) return;
    final result = await sl<GetStudentByParentIdUseCase>().call(params: parentUid);
    result.fold((_) => emit(null), (student) => emit(student));
  }

  Future<void> refresh(String parentUid) async {
    await _load(parentUid);
  }
}
