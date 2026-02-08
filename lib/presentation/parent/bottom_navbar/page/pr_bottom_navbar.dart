import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/parent/bottom_navbar/bloc/bottom_navbar_index_cubit.dart';
import 'package:polen_academy/presentation/parent/bottom_navbar/bloc/bottom_navbar_page_title_cubit.dart';
import 'package:polen_academy/presentation/parent/home/page/pr_home.dart';
import 'package:polen_academy/presentation/parent/homeworks/page/homeworks.dart';
import 'package:polen_academy/presentation/parent/menu/page/pr_menu.dart';
import 'package:polen_academy/presentation/parent/practice_test/page/pr_practice_test.dart';

class PrBottomNavbarPage extends StatelessWidget {
  const PrBottomNavbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PrBottomNavbarIndexCubit()),
        BlocProvider(create: (_) => PrBottomNavbarPageTitleCubit()),
      ],
      child: BlocBuilder<PrBottomNavbarIndexCubit, int>(
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
    const PrHomePage(),
    const PrHomeworksPage(), // Ödevler sayfası gelince değişir
    const PrPracticeTestPage(),
    const PrMenuPage(),
  ];

  /// ---------------- APP BAR ----------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: true,
      elevation: 0,
      title: BlocBuilder<PrBottomNavbarPageTitleCubit, String>(
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
        context.read<PrBottomNavbarIndexCubit>().changeIndex(index);
        context.read<PrBottomNavbarPageTitleCubit>().changeTitle(index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Ödevler'),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Denemeler', // Practice Tests / Mock Exams
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menü'),
      ],
    );
  }
}
