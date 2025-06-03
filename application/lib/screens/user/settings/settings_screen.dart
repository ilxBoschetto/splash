import 'package:flutter/material.dart';
import 'package:application/notifiers/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const SettingsScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Impostazioni",
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text("Tema Chiaro"),
            secondary: const Icon(Icons.light_mode),
            value: ThemeMode.light,
            groupValue: themeNotifier.value,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Tema Scuro"),
            secondary: const Icon(Icons.dark_mode),
            value: ThemeMode.dark,
            groupValue: themeNotifier.value,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Sistema"),
            secondary: const Icon(Icons.settings),
            value: ThemeMode.system,
            groupValue: themeNotifier.value,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(mode);
            },
          ),
        ],
      ),
    );
  }
}
