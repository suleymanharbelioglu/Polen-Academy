import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/notification_bell_button.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/presentation/parent/bloc/parent_student_cubit.dart';
import 'package:polen_academy/presentation/parent/bottom_navbar/bloc/bottom_navbar_index_cubit.dart';
import 'package:polen_academy/presentation/parent/bottom_navbar/bloc/bottom_navbar_page_title_cubit.dart';
import 'package:polen_academy/presentation/parent/bottom_navbar/widget/parent_profile_drawer.dart';
import 'package:polen_academy/presentation/parent/goals/page/pr_goals.dart';
import 'package:polen_academy/presentation/parent/home/page/pr_home.dart';
import 'package:polen_academy/presentation/parent/homeworks/page/homeworks.dart';
import 'package:polen_academy/presentation/parent/menu/page/pr_menu.dart';
import 'package:polen_academy/presentation/parent/my_agenda/page/pr_my_agenda.dart';
import 'package:polen_academy/service_locator.dart';

class PrBottomNavbarPage extends StatefulWidget {
  const PrBottomNavbarPage({super.key});

  @override
  State<PrBottomNavbarPage> createState() => _PrBottomNavbarPageState();
}

class _PrBottomNavbarPageState extends State<PrBottomNavbarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final parentUid = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ParentStudentCubit(parentUid: parentUid)),
        BlocProvider(create: (_) => PrBottomNavbarIndexCubit()),
        BlocProvider(create: (_) => PrBottomNavbarPageTitleCubit()),
      ],
      child: BlocBuilder<PrBottomNavbarIndexCubit, int>(
        builder: (context, index) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            drawer: const ParentProfileDrawer(),
            body: _pages[index],
            bottomNavigationBar: _buildBottomNavBar(context, index),
          );
        },
      ),
    );
  }

  /// ---------------- PAGE LIST (öğrenci ile aynı sıra) ----------------
  static final List<Widget> _pages = [
    const PrHomePage(),
    const PrGoalsPage(),
    const PrHomeworksPage(),
    const PrMyAgendaPage(),
    const PrMenuPage(),
  ];

  /// ---------------- APP BAR ----------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryParent,
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
        child: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: FutureBuilder<Map<String, String>?>(
            future: sl<AuthFirebaseService>().getCurrentUserDisplayInfo(),
            builder: (context, snapshot) {
              final name = snapshot.data?['firstName']?.trim();
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
      selectedItemColor: AppColors.primaryParent,
      unselectedItemColor: Colors.white,
      onTap: (index) {
        context.read<PrBottomNavbarIndexCubit>().changeIndex(index);
        context.read<PrBottomNavbarPageTitleCubit>().changeTitle(index);
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
