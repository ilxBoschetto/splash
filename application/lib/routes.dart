import 'package:flutter/material.dart';
import 'screens/fontanelle_screen.dart';
import 'screens/fontanelle_details_screen.dart';
import 'screens/mappe_screen.dart';
import 'screens/user_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'app_layout.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const AppLayout(),
  '/fontanelle': (context) => const FontanelleListScreen(),
  '/mappe': (context) => const MappeScreen(),
  '/utente': (context) => const UserScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/dettagli_fontanella': (context) => FontanellaDetailScreen(),
  '/profile': (context) => const ProfileScreen(),
};
