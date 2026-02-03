
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentBottomNavbarIndexCubit extends Cubit<int> {
  StudentBottomNavbarIndexCubit() : super(0);

  void changeIndex(int index) {
    emit(index);
  }
}
