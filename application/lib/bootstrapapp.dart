import 'package:flutter/material.dart';
import 'package:application/notifiers/theme_notifier.dart';
import 'package:application/helpers/auth_helper.dart';
import 'app.dart';

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final ThemeNotifier _themeNotifier;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
    _init();
  }

  Future<void> _init() async {
    try {
      await _themeNotifier.ensureInitialized();

      await AuthHelper.checkLogin().timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
    } catch (e, s) {
      // TODO: Find a way to report errors to development team
      debugPrint('Bootstrap error: $e\n$s');
    }

    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MyApp(themeNotifier: _themeNotifier);
  }
}
