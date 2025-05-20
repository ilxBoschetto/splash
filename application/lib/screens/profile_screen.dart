import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserData();
    initializeDateFormatting('it_IT').then((_) {
      setState(() {
        _userFuture = fetchUserData();
      });
    });
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final url = '${dotenv.env['API_URL']}/profile';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore durante il recupero dei dati profilo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Nessun dato disponibile'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Nome',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                user['name'] ?? 'N/D',
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.green),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Email',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                user['email'] ?? 'N/D',
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      if (user['created_at'] != null)
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Registrato il',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd MMMM yyyy',
                                    'it_IT',
                                  ).format(DateTime.parse(user['created_at'])),
                                  textAlign: TextAlign.right,
                                  style:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
