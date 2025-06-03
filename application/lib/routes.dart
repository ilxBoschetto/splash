import 'package:application/notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'screens/fontanelle_screen.dart';
import 'screens/fontanelle_details_screen.dart';
import 'screens/mappe_screen.dart';
import 'screens/user_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/app_information_screen.dart';
import 'screens/community_screen.dart';
import 'app_layout.dart';

Map<String, WidgetBuilder> appRoutes(ThemeNotifier themeNotifier) {
  return {
    '/': (_) => const AppLayout(),
    '/fontanelle': (_) => const FontanelleListScreen(),
    '/mappe': (_) => const MappeScreen(),
    '/utente': (_) => const UserScreen(),
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/dettagli_fontanella': (_) => FontanellaDetailScreen(),
    '/profile': (_) => const ProfileScreen(),
    '/app_information': (_) => const AppInformationScreen(),
    '/community': (_) => const CommunityScreen(),
    '/settings': (_) => SettingsScreen(themeNotifier: themeNotifier),
  };
}
