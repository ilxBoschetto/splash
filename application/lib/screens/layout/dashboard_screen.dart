import 'package:application/helpers/auth_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../helpers/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isUserLogged = false;
  bool loading = true;
  final userSession = UserSession();

  int totalFontanelle = 0;
  int fontanelleOggi = 0;
  int fontanelleUser = 0;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _loadDashboardStats();
  }

  void _checkUserStatus() async {
    await AuthHelper.checkLogin();
    setState(() {
      isUserLogged = AuthHelper.isUserLogged;
      loading = false;
    });
  }

  Future<void> _loadDashboardStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        totalFontanelle = prefs.getInt('totalFontanelle') ?? 0;
        fontanelleOggi = prefs.getInt('fontanelleOggi') ?? 0;
        fontanelleUser = prefs.getInt('fontanelleUser') ?? 0;
      });
      final userSession = UserSession();
      final res1 = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/fontanelle/count'),
      );
      final res2 = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/fontanelle/today'),
      );
      if (isUserLogged) {
        final res3 = await http.get(
          Uri.parse(
            '${dotenv.env['API_URL']}/users/${userSession.userId}/saved_fontanella_count',
          ),
        );

        if (res3.statusCode == 200) {
          fontanelleUser = json.decode(res3.body)['count'];
          prefs.setInt('fontanelleUser', fontanelleUser);
        }
      }

      if (res1.statusCode == 200) {
        totalFontanelle = json.decode(res1.body)['count'];
        prefs.setInt('totalFontanelle', totalFontanelle);
      }

      if (res2.statusCode == 200) {
        fontanelleOggi = json.decode(res2.body)['count'];
        prefs.setInt('fontanelleOggi', fontanelleOggi);
      }

      setState(() {});
    } catch (e) {
      print('Errore durante il caricamento delle statistiche: $e');
    }
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
          'menu.dashboard'.tr(),
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
        padding: const EdgeInsets.all(16),
        children: [
          Image.asset(
            'assets/icons/logo.png',
            height: 150, // imposta una height massima
          ),

          if (!isUserLogged) ...[
            const _LoginPrompt(),
            const SizedBox(height: 16),
          ],
          _DashboardCard(
            title: 'drinking_fountain.total'.tr(),
            value: "$totalFontanelle",
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'drinking_fountain.added_today'.tr(),
            value: "$fontanelleOggi",
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'drinking_fountain.saved'.tr(),
            value: "$fontanelleUser",
            color: Colors.green,
            onTap:
                isUserLogged && fontanelleUser > 0
                    ? () {
                      Navigator.pushNamed(
                        context,
                        '/fontanelle',
                        arguments: {'filter': 'saved_fontanelle'},
                      );
                    }
                    : null,
            showArrow: isUserLogged && fontanelleUser > 0,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final bool showArrow;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              // Contenuto principale occupa tutto lo spazio disponibile
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).hintColor,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'drinking_fountain.save_drinkin_fountain_by_doing_login'
                        .tr(),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Center(
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            'general.register'.tr().toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).scaffoldBackgroundColor,
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
                            'general.login'.tr().toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).scaffoldBackgroundColor,
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
    );
  }
}
