import 'package:application/notifiers/theme_notifier.dart';
import 'package:application/screens/components/version_check_wrapper.dart';
import 'package:application/screens/user/administration/administration_screen.dart';
import 'package:flutter/material.dart';
import 'screens/layout/fontanelle_screen.dart';
import 'screens/fontanelle/fontanelle_details_screen.dart';
import 'screens/layout/mappe_screen.dart';
import 'screens/layout/user_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/profile/profile_screen.dart';
import 'screens/user/settings/settings_screen.dart';
import 'screens/user/app_information/app_information_screen.dart';
import 'screens/user/community/community_screen.dart';

Map<String, WidgetBuilder> appRoutes(ThemeNotifier themeNotifier) {
  return {
    '/': (_) => const VersionCheckWrapper(),
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
    '/administration': (_) => const AdministrationScreen(),
  };
}
