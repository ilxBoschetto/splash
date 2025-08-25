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
      body: ListView(
        children: [
          // Sezione Tema
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'theme'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
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

          const Divider(),

          // Sezione Lingua
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'language'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: DropdownButton<Locale>(
              value: context.locale,
              items: context.supportedLocales.map((locale) {
                return DropdownMenuItem(
                  value: locale,
                  child: Text(_getLanguageName(locale)),
                );
              }).toList(),
              onChanged: (locale) {
                if (locale != null) {
                  context.setLocale(locale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper per mostrare i nomi delle lingue leggibili
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'it':
        return 'Italiano';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return locale.languageCode;
    }
  }
}
