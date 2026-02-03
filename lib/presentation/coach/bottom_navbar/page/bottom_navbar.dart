import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/bloc/bottom_navbar_index_cubit.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/bloc/bottom_navbar_page_title_cubit.dart';
import 'package:polen_academy/presentation/coach/goals/page/goals.dart';
import 'package:polen_academy/presentation/coach/home/page/home.dart';
import 'package:polen_academy/presentation/coach/homeworks/page/homeworks.dart';
import 'package:polen_academy/presentation/coach/menu/page/menu.dart';
import 'package:polen_academy/presentation/coach/my_agenda/page/my_agenda.dart';

class BottomNavbarPage extends StatelessWidget {
  const BottomNavbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavbarIndexCubit()),
        BlocProvider(create: (_) => BottomNavbarPageTitleCubit()),
      ],
      child: BlocBuilder<BottomNavbarIndexCubit, int>(
        builder: (context, index) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: _pages[index],
            bottomNavigationBar: _buildBottomNavBar(context, index),
          );
        },
      ),
    );
  }

  /// ---------------- PAGE LIST ----------------
  static final List<Widget> _pages = [
    const HomePage(),
    const GoalsPage(),
    const HomeworksPage(), // Ödevler sayfası gelince değişir
    const MyAgendaPage(),
    const MenuPage(),
  ];

  /// ---------------- APP BAR ----------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: true,
      elevation: 0,
      title: BlocBuilder<BottomNavbarPageTitleCubit, String>(
        builder: (context, title) {
          return Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        },
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  /// ---------------- BOTTOM NAVBAR ----------------
  Widget _buildBottomNavBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.white,
      onTap: (index) {
        context.read<BottomNavbarIndexCubit>().changeIndex(index);
        context.read<BottomNavbarPageTitleCubit>().changeTitle(index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Hedefler'),
        BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Ödevler'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Ajandam',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menü'),
      ],
    );
  }
}
