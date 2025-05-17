import 'package:flutter/material.dart';
import 'app_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      themeMode: ThemeMode.dark,
      home: const AppLayout(),
    );
  }
}
