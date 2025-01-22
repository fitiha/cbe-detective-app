import 'package:receipt_validator/views/auth/login_page.dart';
import 'package:receipt_validator/views/auth/register_page.dart';
import 'package:receipt_validator/views/pages/profile_page.dart';
import 'package:receipt_validator/views/pages/settings_page.dart';
import 'package:receipt_validator/views/screens/main_screen.dart';
import 'package:receipt_validator/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    SplashScreen.route: (context) => SplashScreen(),
    LoginPage.route: (context) => LoginPage(),
    RegisterPage.route: (context) => RegisterPage(),
    MainScreen.route: (context) => MainScreen(),
    ProfilePage.route: (context) => ProfilePage(),
    SettingsPage.route: (context) => SettingsPage(),
  };
}
