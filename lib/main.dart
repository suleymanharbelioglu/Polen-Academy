import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_theme.dart';
import 'package:polen_academy/data/notification/fcm_service.dart';
import 'package:polen_academy/firebase_options.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_cubit.dart';
import 'package:polen_academy/presentation/splash/page/splash.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:polen_academy/service_locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Arka planda bildirim geldiğinde (uygulama kapalı/arka planda)
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeDependencies();
  // FCM token'ı giriş yapmış kullanıcı için Firestore'a kaydet (push bildirimleri için)
  FcmService.saveTokenIfLoggedIn();
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
