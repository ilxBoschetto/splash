import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:application/notifiers/theme_notifier.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
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
          title: 'Fontanelle App',
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
