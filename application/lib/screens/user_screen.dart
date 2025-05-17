import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final version = dotenv.env['APP_VERSION'] ?? 'v?';

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni Utente')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Info',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Developed by Matteo Boschetti',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Versione: $version',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Profilo e impostazioni'),
            ),
          ),
        ],
      ),
    );
  }
}
