import 'package:easy_localization/easy_localization.dart';
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
          'settings'.tr(),
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
          /*
          RadioListTile<ThemeMode>(
            title: Text('light_theme'.tr()),
            secondary: const Icon(Icons.light_mode),
            value: ThemeMode.light,
            groupValue: themeNotifier.value,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(ThemeMode.light);
            },
          ),
          */
          RadioListTile<ThemeMode>(
            title: Text('dark_theme'.tr()),
            secondary: const Icon(Icons.dark_mode),
            value: ThemeMode.dark,
            groupValue: themeNotifier.value,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}
