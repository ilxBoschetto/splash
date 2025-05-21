import 'package:flutter/material.dart';
import 'package:application/notifiers/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const SettingsScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Impostazioni")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Tema Chiaro"),
            leading: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: themeNotifier.value,
              onChanged: (mode) {
                if (mode != null) themeNotifier.setTheme(mode);
              },
            ),
          ),
          ListTile(
            title: const Text("Tema Scuro"),
            leading: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: themeNotifier.value,
              onChanged: (mode) {
                if (mode != null) themeNotifier.setTheme(mode);
              },
            ),
          ),
          ListTile(
            title: const Text("Sistema"),
            leading: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: themeNotifier.value,
              onChanged: (mode) {
                if (mode != null) themeNotifier.setTheme(mode);
              },
            ),
          ),
        ],
      ),
    );
  }
}
