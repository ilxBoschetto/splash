import 'package:application/helpers/auth_helper.dart';
import 'package:application/helpers/user_session.dart';
import 'package:flutter/material.dart';
import 'package:application/models/fontanella.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:application/screens/components/minimal_notification.dart';
import '../../helpers/location_helper.dart';
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
  int fontanellaVotes = 0;
  LatLng? userPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Fontanella) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return;
    }

    fontanella = args;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStatusAndFetch();
      _getFontanellaVotes();
    });
  }

  Future<void> loadCachedUserPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('cached_lat');
    final lon = prefs.getDouble('cached_lon');
    if (lat != null && lon != null) {
      setState(() {
        userPosition = LatLng(lat, lon);
      });
    }
  }

  void _checkUserStatusAndFetch() async {
    await AuthHelper.checkLogin();
    setState(() {
      isUserLogged = AuthHelper.isUserLogged;
    });
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

  Future<void> _getFontanellaVotes() async {
    final fontanellaId = fontanella.id;
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/fontanelle/$fontanellaId/vote'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fontanellaVotes = data['total'] ?? 0;
      });
    } else {
      debugPrint('Errore nel salvataggio: ${response.statusCode}');
      showMinimalNotification(
        context,
        message: 'Errore',
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _voteFontanella(String vote) async {
    final fontanellaId = fontanella.id;
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/fontanelle/$fontanellaId/vote'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'vote': vote}),
    );
    if (response.statusCode == 200) {
      _getFontanellaVotes();
      showMinimalNotification(
        context,
        message: 'Fontanella votata!',
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
  }

  Future<void> _removeFromSaved() async {
    final uid = userSession.userId;
    if (uid == null) return;

    try {
      final fontanellaId = fontanella.id;
      final response = await http.delete(
        Uri.parse(
          '${dotenv.env['API_URL']}/user/$uid/saved_fontanella/$fontanellaId',
        ),
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
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showMinimalNotification(
        context,
        message: 'Errore nell\'apertura di Google Maps',
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          Navigator.pop(context, true);
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child:
                              fontanella.imageUrl != ""
                                  ? Image.network(
                                    '${dotenv.env['API_URI']}/api/uploads/${fontanella.imageUrl}',
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/icons/favicon.png',
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          shape: CircleBorder(),
                          child: InkWell(
                            customBorder: CircleBorder(),
                            onTap: () {
                              _voteFontanella('up');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.thumb_up_alt,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 25,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),
                        Text(
                          fontanellaVotes.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Material(
                          color: Colors.transparent,
                          shape: CircleBorder(),
                          child: InkWell(
                            customBorder: CircleBorder(),
                            onTap: () {
                              _voteFontanella('down');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.thumb_down_alt,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 25,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Distanza',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      LocationHelper.formatDistanza(fontanella.distanza),
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Latitudine',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text('${fontanella.lat}', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),
                    Text(
                      'Longitudine',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text('${fontanella.lon}', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),
                    Text(
                      'Creato da',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      fontanella.createdBy?.name ?? '-',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Icon(Icons.map, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
