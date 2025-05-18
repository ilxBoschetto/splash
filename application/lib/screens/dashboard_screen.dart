import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showBanner = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Stack(
        children: [
          const Center(child: Text('Benvenuto nella Dashboard')),
          if (_showBanner)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Salva le tue fontanelle creando un account o facendo il login.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4), // Bordi meno arrotondati
                              ),
                            ),
                            onPressed: () {
                              setState(() => _showBanner = false);
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'REGISTRATI',
                              style: (
                                TextStyle(fontWeight: FontWeight.w900,
                                          color: Theme.of(context).scaffoldBackgroundColor)
                                ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () {
                              setState(() => _showBanner = false);
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              'LOGIN',
                              style: (
                                TextStyle(fontWeight: FontWeight.w900,
                                          color: Theme.of(context).scaffoldBackgroundColor)
                                ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
