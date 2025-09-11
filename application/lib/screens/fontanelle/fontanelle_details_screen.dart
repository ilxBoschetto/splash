import 'package:application/enum/potability_enum.dart';
import 'package:application/helpers/auth_helper.dart';
import 'package:application/helpers/user_session.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:application/models/fontanella.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:application/screens/components/minimal_notification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
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
  String userVote = '';
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
          '${dotenv.env['API_URL']}/users/$uid/saved_fontanella/check/${fontanella.id}',
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
        Uri.parse('${dotenv.env['API_URL']}/users/$uid/saved_fontanella'),
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
          message: 'drinking_fountain.saved_action'.tr(),
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        debugPrint('Errore nel salvataggio: ${response.statusCode}');
        showMinimalNotification(
          context,
          message: 'errors.save'.tr(),
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
        message: 'errors.server_error'.tr(),
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
        userVote = data['userVote'] ?? '';
      });
    } else {
      debugPrint('Errore nel salvataggio: ${response.statusCode}');
      showMinimalNotification(
        context,
        message: 'errors.general_error'.tr(),
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
        message: 'drinking_fountain.voted_action'.tr(),
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      debugPrint('Errore nel salvataggio: ${response.statusCode}');
      showMinimalNotification(
        context,
        message: 'errors.save'.tr(),
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
          '${dotenv.env['API_URL']}/users/$uid/saved_fontanella/$fontanellaId',
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
          message: 'drinking_fountain.unsaved_action'.tr(),
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        debugPrint('Errore nella rimozione: ${response.statusCode}');
        showMinimalNotification(
          context,
          message: 'errors.unsave'.tr(),
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
        message: 'errors.opening_google_maps'.tr(),
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
          child: SingleChildScrollView(
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
                            width: 200,
                            height: 200,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.all(10),
                                      child: InteractiveViewer(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${dotenv.env['API_URL']}/uploads/${fontanella.imageUrl}',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl:
                                    '${dotenv.env['API_URI']}/api/uploads/${fontanella.imageUrl}',
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[800]!,
                                      highlightColor: Colors.grey[700]!,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[800],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Image.asset(
                                      'assets/icons/favicon.png',
                                      fit: BoxFit.cover,
                                    ),
                              ),
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
                                if (isUserLogged) {
                                  _voteFontanella('up');
                                } else {
                                  Navigator.pushNamed(context, '/login');
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        userVote == 'up'
                                            ? Colors.green
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.thumb_up_alt,
                                  color:
                                      userVote == 'up'
                                          ? Colors.green
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
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
                                if (isUserLogged) {
                                  _voteFontanella('down');
                                } else {
                                  Navigator.pushNamed(context, '/login');
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        userVote == 'down'
                                            ? Colors.red
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.thumb_down_alt,
                                  color:
                                      userVote == 'down'
                                          ? Colors.red
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
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
                        'drinking_fountain.distance'.tr(),
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
                        'drinking_fountain.latitude'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text('${fontanella.lat}', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 12),
                      Text(
                        'drinking_fountain.longitude'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text('${fontanella.lon}', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 12),
                      Text(
                        'drinking_fountain.created_by'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        fontanella.createdBy?.name ?? '-',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'drinking_fountain.potable'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            () {
                              switch (fontanella.potability) {
                                case Potability.potable:
                                  return Icons.invert_colors;
                                case Potability.notPotable:
                                  return Icons.invert_colors_off;
                                case Potability.unknown:
                                default:
                                  return Icons.invert_colors;
                              }
                            }(),
                            color: () {
                              switch (fontanella.potability) {
                                case Potability.potable:
                                  return Colors.lightBlue;
                                case Potability.notPotable:
                                  return Colors.orange;
                                case Potability.unknown:
                                default:
                                  return Colors.grey;
                              }
                            }(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fontanella.potability != null
                                ? () {
                                  switch (fontanella.potability) {
                                    case Potability.potable:
                                      return 'drinking_fountain.potable'.tr();
                                    case Potability.notPotable:
                                      return 'drinking_fountain.not_potable'
                                          .tr();
                                    case Potability.unknown:
                                    default:
                                      return 'drinking_fountain.unknown'.tr();
                                  }
                                }()
                                : '-',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
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
      ),
    );
  }
}
