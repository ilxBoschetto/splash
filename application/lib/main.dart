import 'package:application/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:application/notifiers/theme_notifier.dart';
import 'dart:convert';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AuthHelper.checkLogin();
  runApp(MyApp());
  checkAppVersion();
}

class MyApp extends StatelessWidget {
  final ThemeNotifier themeNotifier = ThemeNotifier();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Splash',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color.fromARGB(255, 41, 41, 41),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 27, 27, 27),
              foregroundColor: Color.fromARGB(255, 238, 238, 238),
            ),
            textTheme: const TextTheme(
              bodySmall: TextStyle(
                color: Color.fromARGB(255, 160, 160, 160),
                fontSize: 12,
              ),
            ),
          ),
          themeMode: currentThemeMode,
          initialRoute: '/',
          routes: appRoutes(themeNotifier), // Passa il notifier ai routes
        );
      },
    );
  }
}

Future<void> checkAppVersion() async {
  final String apiUrl = dotenv.env['APP_VERSION_CHECK_URL'] ?? '';
  final String currentVersion = dotenv.env['APP_VERSION'] ?? '';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String latestVersion = data['latestVersion'];
      String minSupportedVersion = data['minSupportedVersion'];
      // String playStoreUrl = data['playStoreUrl'];

      if (_isVersionLower(currentVersion, minSupportedVersion)) {
        print(
          'Aggiornamento obbligatorio: la tua versione non è più supportata.',
        );
      } else if (_isVersionLower(currentVersion, latestVersion)) {
        print('Aggiornamento disponibile: nuova versione presente.');
      } else {
        print('L\'app è aggiornata.');
      }
    } else {
      print('Errore nella chiamata: ${response.statusCode}');
    }
  } catch (e) {
    print('Errore nella richiesta: $e');
  }
}

bool _isVersionLower(String current, String target) {
  final currentParts = current.split('.').map(int.parse).toList();
  final targetParts = target.split('.').map(int.parse).toList();

  for (int i = 0; i < targetParts.length; i++) {
    final currentPart = i < currentParts.length ? currentParts[i] : 0;
    final targetPart = targetParts[i];

    if (currentPart < targetPart) return true;
    if (currentPart > targetPart) return false;
  }

  return false;
}
