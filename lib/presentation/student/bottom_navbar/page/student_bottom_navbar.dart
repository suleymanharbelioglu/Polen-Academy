import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/student/bottom_navbar/bloc/student_bottom_navbar_index_cubit.dart';
import 'package:polen_academy/presentation/student/bottom_navbar/bloc/student_bottom_navbar_page_title_cubit.dart';
import 'package:polen_academy/presentation/student/goals/page/student_goals.dart';
import 'package:polen_academy/presentation/student/home/page/st_home.dart';
import 'package:polen_academy/presentation/student/homeworks/page/st_homeworks.dart';
import 'package:polen_academy/presentation/student/menu/page/st_menu.dart';
import 'package:polen_academy/presentation/student/my_agenda/page/st_my_agenda.dart';

class StudentBottomNavbarPage extends StatelessWidget {
  const StudentBottomNavbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StudentBottomNavbarIndexCubit()),
        BlocProvider(create: (_) => StudentBottomNavbarPageTitleCubit()),
      ],
      child: BlocBuilder<StudentBottomNavbarIndexCubit, int>(
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
    const StHomePage(),
    const StudentGoalsPage(),
    const StHomeworksPage(),
    const StMyAgendaPage(),
    const StMenuPage(),
  ];

  /// ---------------- APP BAR ----------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryStudent,
      centerTitle: true,
      elevation: 0,
      title: BlocBuilder<StudentBottomNavbarPageTitleCubit, String>(
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
      selectedItemColor: AppColors.primaryStudent,
      unselectedItemColor: Colors.white,
      onTap: (index) {
        context.read<StudentBottomNavbarIndexCubit>().changeIndex(index);
        context.read<StudentBottomNavbarPageTitleCubit>().changeTitle(index);
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
