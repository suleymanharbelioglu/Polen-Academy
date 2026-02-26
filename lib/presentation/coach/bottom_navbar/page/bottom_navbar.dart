import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/bloc/bottom_navbar_index_cubit.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/bloc/bottom_navbar_page_title_cubit.dart';
import 'package:polen_academy/presentation/coach/goals/page/goals.dart';
import 'package:polen_academy/presentation/coach/home/page/home.dart';
import 'package:polen_academy/presentation/coach/homeworks/page/homeworks.dart';
import 'package:polen_academy/presentation/coach/menu/page/menu.dart';
import 'package:polen_academy/presentation/coach/my_agenda/page/my_agenda.dart';
import 'package:polen_academy/common/widget/notification_bell_button.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/widget/coach_profile_drawer.dart';
import 'package:polen_academy/service_locator.dart';

class BottomNavbarPage extends StatefulWidget {
  const BottomNavbarPage({super.key});

  @override
  State<BottomNavbarPage> createState() => _BottomNavbarPageState();
}

class _BottomNavbarPageState extends State<BottomNavbarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            key: _scaffoldKey,
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            drawer: const CoachProfileDrawer(),
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
      backgroundColor: AppColors.primaryCoach,
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
        child: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: FutureBuilder<String?>(
            future: sl<AuthFirebaseService>().getCurrentCoachFirstName(),
            builder: (context, snapshot) {
              final name = snapshot.data?.trim();
              final initial = name != null && name.isNotEmpty
                  ? name.substring(0, 1).toUpperCase()
                  : null;
              return CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: initial != null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white),
              );
            },
          ),
        ),
      ),
      actions: [
        const NotificationBellButton(iconColor: Colors.white),
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
      selectedItemColor: AppColors.primaryCoach,
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
