import 'package:flutter_bloc/flutter_bloc.dart';

class IsPremiumCubit extends Cubit<bool> {
  IsPremiumCubit() : super(false);

  void setPremium(bool value) => emit(value);

  void activatePremium() => emit(true);

  void reset() => emit(false);
}

