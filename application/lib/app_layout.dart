import 'package:flutter/material.dart';
import 'screens/layout/dashboard_screen.dart';
import 'screens/layout/fontanelle_screen.dart';
import 'screens/layout/mappe_screen.dart';
import 'screens/layout/user_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    FontanelleListScreen(),
    MappeScreen(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInBack),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: PhysicalModel(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 20,
        child: ConvexAppBar(
          style: TabStyle.react,
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Colors.grey.shade500,
          activeColor: Theme.of(context).colorScheme.primary,
          curveSize: 90,
          height: 60,
          initialActiveIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            TabItem(icon: Icons.dashboard_outlined, title: 'Dashboard'),
            TabItem(icon: Icons.water_drop_outlined, title: 'Fontanelle'),
            TabItem(icon: Icons.map_outlined, title: 'Mappe'),
            TabItem(icon: Icons.account_circle_outlined, title: 'Utente'),
          ],
        ),
      ),
    );
  }
}
