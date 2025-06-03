import 'package:flutter/material.dart';
import 'package:application/models/fontanella.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../helpers/user_session.dart';
import 'dart:convert';

class FontanellaDetailScreen extends StatefulWidget {
  const FontanellaDetailScreen({super.key});

  @override
  State<FontanellaDetailScreen> createState() => _FontanellaDetailScreenState();
}

class _FontanellaDetailScreenState extends State<FontanellaDetailScreen> {
  late Fontanella fontanella;
  bool isSaved = false;
  bool isUserLogged = false;
  final userSession = UserSession();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fontanella = ModalRoute.of(context)!.settings.arguments as Fontanella;
    _checkUserStatusAndFetch();
  }

  void _checkUserStatusAndFetch() async {
    final uid = userSession.userId;

    if (userSession.isLogged && uid != null) {
      setState(() {
        isUserLogged = true;
      });
      await _checkIfSaved(uid);
    } else {
      setState(() {
        isUserLogged = false;
      });
    }
  }

  Future<void> _checkIfSaved(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/$uid/saved_fontanella/check/${fontanella.id}'),
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          isSaved = data['isSaved'] ?? false;
        });
      } else {
        debugPrint('Errore nel recupero dello stato di salvataggio: ${response.statusCode}');
        setState(() {
          isSaved = false;
        });
      }
    } catch (e) {
      debugPrint('Eccezione durante il check dello stato di salvataggio: $e');
      setState(() {
        isSaved = false;
      });
    }
  }

  Future<void> _addToSaved() async {
    final uid = userSession.userId;
    if (uid == null) return;

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/user/$uid/saved_fontanella'),
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fontanellaId': fontanella.id}),
      );

      if (response.statusCode == 201) {
        setState(() => isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fontanella salvata con successo')),
        );
      } else {
        debugPrint('Errore nel salvataggio: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante il salvataggio')),
        );
      }
    } catch (e) {
      debugPrint('Errore nel salvataggio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di connessione: $e')),
      );
    }
  }

  Future<void> _removeFromSaved() async {
    final uid = userSession.userId;
    if (uid == null) return;

    try {
      final response = await http.delete(
        Uri.parse(
          '${dotenv.env['API_URL']}/user/$uid/saved_fontanella',
        ),
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fontanellaId': fontanella.id}),
      );

      if (response.statusCode == 200) {
        setState(() => isSaved = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fontanella rimossa dai preferiti')),
        );
      } else {
        debugPrint('Errore nella rimozione: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante la rimozione')),
        );
      }
    } catch (e) {
      debugPrint('Errore nella rimozione: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di connessione: $e')),
      );
    }
  }

  Future<void> _openInMaps(double lat, double lon) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon', // URL corretto per Google Maps
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossibile aprire Google Maps. Assicurati che l\'app sia installata.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          fontanella.nome,
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions:
            isUserLogged
                ? [
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        isSaved ? _removeFromSaved() : _addToSaved();
                      },
                    ),
                  ]
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latitudine: ${fontanella.lat}'),
                      Text('Longitudine: ${fontanella.lon}'),
                      Text(
                        'Distanza: ${fontanella.distanza.toStringAsFixed(2)} km',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _openInMaps(fontanella.lat, fontanella.lon);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Apri in Google Maps'),
            ),
          ],
        ),
      ),
    );
  }
}