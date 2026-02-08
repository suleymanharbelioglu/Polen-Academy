import 'package:flutter_bloc/flutter_bloc.dart';

class PrBottomNavbarPageTitleCubit extends Cubit<String> {
  PrBottomNavbarPageTitleCubit() : super('Anasayfa');

  void changeTitle(int index) {
    switch (index) {
      case 0:
        emit('Anasayfa');
        break;

      case 1:
        emit('Ödevler');
        break;
      case 2:
        emit('Denemeler');
        break;
      case 3:
        emit('Menü');
        break;
    }
  }
}
