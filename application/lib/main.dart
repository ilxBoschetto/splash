import 'package:application/notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:application/helpers/auth_helper.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AuthHelper.checkLogin();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.ensureInitialized();

  runApp(MyApp(themeNotifier: themeNotifier));
}
