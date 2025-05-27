import 'package:flutter/material.dart';
import '../helpers/auth_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isUserLogged = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    await AuthHelper.checkLogin();
    setState(() {
      isUserLogged = AuthHelper.isUserLogged;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Stack(
        children: [
          const Center(child: Text('Benvenuto nella Dashboard')),
          if (!isUserLogged)
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
                          Center(
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/register');
                                    },
                                    child: Text(
                                      'REGISTRATI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color:
                                            Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color:
                                            Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
