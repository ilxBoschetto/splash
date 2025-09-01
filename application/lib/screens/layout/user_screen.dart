import 'package:application/helpers/auth_helper.dart';
import 'package:application/helpers/user_session.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool isUserLogged = false;

  final userSession = UserSession();

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
          'user_settings'.tr(),
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
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    label: 'profile'.tr(),
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
                    label: 'settings'.tr(),
                    icon: Icons.settings,
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    label: 'community'.tr(),
                    icon: Icons.people,
                    onTap: () => Navigator.pushNamed(context, '/community'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    label: 'app_information'.tr(),
                    icon: Icons.info_outline,
                    onTap:
                        () => Navigator.pushNamed(context, '/app_information'),
                  ),
                  if (userSession.isLogged && userSession.isAdmin == true) ...[
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      label: 'administration'.tr(),
                      icon: Icons.admin_panel_settings_outlined,
                      onTap:
                          () => Navigator.pushNamed(context, '/administration'),
                    ),
                  ],
                  if (isUserLogged) ...[
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      label: 'general.logout'.tr(),
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
                                title: Text('confirm_logout'.tr()),
                                content: Text(
                                  '${'are_you_sure_you_want_to_logout'.tr()}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text('general.cancel'.tr()),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text(
                                      'general.logout'.tr(),
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
      color: Theme.of(context).colorScheme.surface,
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
