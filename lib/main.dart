import 'package:firebase_core/firebase_core.dart';
import 'package:receipt_validator/core/constants.dart';
import 'package:receipt_validator/routes.dart';
import 'package:receipt_validator/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//GetX for state management and routing

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  await GetStorage.init();

  ErrorWidget.builder = (details) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
            useMaterial3: true,
            fontFamily: 'Montserrat',
            scaffoldBackgroundColor: Colors.white,
          ),
        );
      },
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
            useMaterial3: true,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            fontFamily: 'Lexend',
            scaffoldBackgroundColor: Colors.white,
          ),
          initialRoute: SplashScreen.route,
          routes: getRoutes(),
        );
      },
    );
  }
}
