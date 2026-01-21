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
  bool _error = false;

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
      debugPrint('Bootstrap error: $e\n$s');
      _error = true;
    }

    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _ready
          ? MyApp(themeNotifier: _themeNotifier)
          : Scaffold(
              body: Center(
                child: _error
                    ? const Text('Errore durante il caricamento')
                    : const CircularProgressIndicator(),
              ),
            ),
    );
  }
}
