import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool isUserLogged = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    await AuthHelper.checkLogin();
    setState(() {
      isUserLogged = AuthHelper.isUserLogged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Impostazioni Utente",
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    97,
                    96,
                    96,
                  ).withAlpha((0.1 * 255).round()),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  label: 'Profilo',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      isUserLogged ? '/profile' : '/login',
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  label: 'Impostazioni',
                  icon: Icons.settings,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  label: 'Community',
                  icon: Icons.people,
                  onTap: () => Navigator.pushNamed(context, '/community'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  label: 'Informazioni Applicazione',
                  icon: Icons.info_outline,
                  onTap: () => Navigator.pushNamed(context, '/app_information'),
                ),
                if (isUserLogged) ...[
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    label: 'Logout',
                    icon: Icons.logout,
                    textColor: Colors.red,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text('Conferma Logout'),
                              content: const Text(
                                'Sei sicuro di voler effettuare il logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Annulla'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirmed == true) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('jwt_token');
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    Color? textColor,
  }) {
    return MenuItemCard(
      label: label,
      icon: icon,
      onTap: onTap,
      color: textColor,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16);
  }
}

class MenuItemCard extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final IconData? icon;

  const MenuItemCard({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        color ?? Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
