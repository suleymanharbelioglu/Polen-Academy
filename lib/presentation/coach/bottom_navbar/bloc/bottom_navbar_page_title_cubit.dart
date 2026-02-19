import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavbarPageTitleCubit extends Cubit<String> {
  BottomNavbarPageTitleCubit() : super('Anasayfa');

  void changeTitle(int index) {
    switch (index) {
      case 0:
        emit('Anasayfa');
        break;
      case 1:
        emit('Hedefler');
        break;
      case 2:
        emit('Ödev Takvimi');
        break;
      case 3:
        emit('Ajandam');
        break;
      case 4:
        emit('Menü');
        break;
    }
  }
}
