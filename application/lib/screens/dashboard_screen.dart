import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Mostra il dialog dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialog();
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accesso richiesto'),
        content: const Text('Per continuare, accedi con il tuo account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Chiudi il dialog
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi il dialog
              Navigator.pushNamed(context, '/login'); // Vai alla login
            },
            child: const Text('Accedi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Benvenuto nella Dashboard')),
    );
  }
}
