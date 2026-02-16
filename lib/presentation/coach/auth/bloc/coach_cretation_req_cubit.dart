import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/data/auth/model/coach.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signup.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_creation_req_state.dart';
import 'package:polen_academy/service_locator.dart';

class CoachCretationReqCubit extends Cubit<CoachCreationReqState> {
  CoachCretationReqCubit() : super(CoachCreationReqInitial());

  Future<void> createCoach(CoachModel coach) async {
    emit(CoachCreationReqLoading());

    try {
      final result = await sl<CoachSignupUseCase>().call(params: coach);

      result.fold(
        (error) {
          print('❌ Kayıt hatası: $error');
          emit(CoachCreationReqFailure(errorMessage: error));
        },
        (success) {
          print('✅ Kayıt başarılı!');
          emit(CoachCreationReqSuccess());
        },
      );
    } catch (e) {
      print('❌ Exception: $e');
      emit(CoachCreationReqFailure(errorMessage: e.toString()));
    }
  }
}
