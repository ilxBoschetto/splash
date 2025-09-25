import 'package:application/helpers/auth_helper.dart';
import 'package:application/screens/components/dashboard/top_users_card.dart';
import 'package:application/screens/components/login_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../helpers/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application/screens/components/dashboard/dashboard_card.dart';

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
  int fontanelleCreatedByUser = 0;
  List<Map<String, dynamic>> topUsers = [];

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
        fontanelleCreatedByUser = prefs.getInt('fontanelleCreatedByUser') ?? 0;
        topUsers =
            (json.decode(prefs.getString('topUsers') ?? '[]') as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList();
      });
      final userSession = UserSession();
      final res1 = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/fontanelle/count'),
      );
      final res2 = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/fontanelle/today'),
      );
      final res5 = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/users/top'),
      );
      if (isUserLogged) {
        final res3 = await http.get(
          Uri.parse(
            '${dotenv.env['API_URL']}/users/${userSession.userId}/saved_fontanella_count',
          ),
        );
        final res4 = await http.get(
          Uri.parse(
            '${dotenv.env['API_URL']}/users/${userSession.userId}/created_fontanella_count',
          ),
        );

        if (res3.statusCode == 200) {
          fontanelleUser = json.decode(res3.body)['count'];
          prefs.setInt('fontanelleUser', fontanelleUser);
        }
        if (res4.statusCode == 200) {
          fontanelleCreatedByUser = json.decode(res4.body)['count'];
          prefs.setInt('fontanelleCreatedByUser', fontanelleCreatedByUser);
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

      if (res5.statusCode == 200) {
        final rawData = json.decode(res5.body) as List<dynamic>? ?? [];

        final List<Map<String, dynamic>> users =
            rawData
                .where((item) => item["user"] != null)
                .map(
                  (item) => {
                    "username": item["user"]?["name"] ?? "Sconosciuto",
                    "score": item["count"] ?? 0,
                  },
                )
                .toList();

        setState(() {
          topUsers = users;
        });
        prefs.setString('topUsers', json.encode(topUsers));
      }
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
            height: 120, // imposta una height massima
          ),

          if (!isUserLogged) ...[
            const LoginPrompt(),
            const SizedBox(height: 16),
          ],
          DashboardCard(
            title: 'drinking_fountain.total'.tr(),
            value: "$totalFontanelle",
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          TopUsersCard(users: topUsers),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'drinking_fountain.added_today'.tr(),
            value: "$fontanelleOggi",
            color: Colors.orange,
          ),

          const SizedBox(height: 12),
          if (isUserLogged) ...[
            DashboardCard(
              title: 'drinking_fountain.created_by_you'.tr(),
              value: "$fontanelleCreatedByUser",
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 12),
          ],
          DashboardCard(
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
