import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_theme.dart';
import 'package:polen_academy/firebase_options.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_cubit.dart';
import 'package:polen_academy/presentation/splash/page/splash.dart';
import 'package:polen_academy/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDependencies();
  // await CurriculumHelper.seedCurriculumIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()..appStarted()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.appTheme,
        title: 'Polen Academy',
        home: SplashPage(),
      ),
    );
  }
}
