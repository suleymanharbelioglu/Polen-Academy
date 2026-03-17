import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/is_premium_cubit.dart';
import 'package:polen_academy/common/helper/curriculum/curriculum_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polen_academy/common/widget/offline_banner.dart';
import 'package:polen_academy/core/configs/theme/app_theme.dart';
import 'package:polen_academy/data/notification/fcm_service.dart';
import 'package:polen_academy/firebase_options.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_cubit.dart';
import 'package:polen_academy/core/configs/screen_design_size.dart';
import 'package:polen_academy/presentation/splash/page/splash.dart';
import 'package:polen_academy/service_locator.dart';

/// Uygulama kapalı veya arka plandayken gelen FCM mesajları.
/// Sunucu sadece "data" (title, body) gönderiyor; bildirimi tam metinle biz gösteriyoruz.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await showBackgroundNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeDependencies();
  // FCM token kaydı + uygulama öndeyken gelen bildirimi sistem bildirimi olarak gösterme
  await FcmService.init();
  //await CurriculumHelper.seedCurriculumIfNeeded();

  // Uygulama her zaman dikey (portre) modda
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final designSize = ScreenDesignSize.size;
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SplashCubit()..appStarted()),
          BlocProvider(create: (context) => IsPremiumCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.appTheme,
          title: 'Polen Academy',
          home: child ?? const SplashPage(),
          builder: (context, child) => Stack(
            alignment: Alignment.topCenter,
            children: [if (child != null) child, const OfflineBanner()],
          ),
        ),
      ),
      child: const SplashPage(),
    );
  }
}
