import 'package:flutter/material.dart';
import 'package:application/models/fontanella.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../helpers/user_session.dart';
import '../../providers/auth_provider.dart';
import 'package:application/screens/components/minimal_notification.dart';
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
    print('${dotenv.env['API_URI']}/uploads/${fontanella.imageUrl}');
    _checkUserStatusAndFetch();
    _checkUserStatus();
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

  void _checkUserStatus() async {
    await AuthHelper.checkLogin();
    setState(() {
      isUserLogged = AuthHelper.isUserLogged;
    });
  }

  Future<void> _checkIfSaved(String uid) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/user/$uid/saved_fontanella/check/${fontanella.id}',
        ),
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isSaved = data['isSaved'] ?? false;
        });
      } else {
        debugPrint(
          'Errore nel recupero dello stato di salvataggio: ${response.statusCode}',
        );
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
        showMinimalNotification(
          context,
          message: 'Fontanella salvata tra i preferiti!',
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        debugPrint('Errore nel salvataggio: ${response.statusCode}');
        showMinimalNotification(
          context,
          message: 'Errore durante il salvataggio',
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Errore nel salvataggio: $e');
      showMinimalNotification(
          context,
          message: 'Errore di connessione',
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
    }
  }

  Future<void> _removeFromSaved() async {
    final uid = userSession.userId;
    if (uid == null) return;

    try {
      final fontanellaId = fontanella.id;
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/user/$uid/saved_fontanella/$fontanellaId'),
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() => isSaved = false);
        showMinimalNotification(
          context,
          message: 'Fontanella rimossa dai preferiti',
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        debugPrint('Errore nella rimozione: ${response.statusCode}');
        showMinimalNotification(
          context,
          message: 'Errore durante la rimozione',
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Errore nella rimozione: $e');
      showMinimalNotification(
          context,
          message: 'Errore di connessione',
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.red,
          textColor: Colors.white,
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          Navigator.pop(context, true); // true = aggiornamento richiesto
        }
      },
      child: Scaffold(
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
                    child:
                        fontanella.imageUrl != null
                            ? Image.network(
                              '${dotenv.env['API_URI']}/uploads/${fontanella.imageUrl}',
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
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
                        Text('Creato da: ${fontanella.createdBy?.name}'),
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
                    showMinimalNotification(
                      context,
                      message: e.toString(),
                      duration: 2500,
                      position: 'bottom',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text('Apri in Google Maps'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
