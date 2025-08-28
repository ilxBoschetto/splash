import 'package:application/screens/components/loaders.dart';
import 'package:application/helpers/location_helper.dart';
import 'package:application/models/fontanella.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class MappeScreen extends StatefulWidget {
  const MappeScreen({super.key});

  @override
  State<MappeScreen> createState() => _MappeScreenState();
}

class _MappeScreenState extends State<MappeScreen> {
  bool isLoading = true;
  final MapController _mapController = MapController();
  List<Fontanella> fontanelle = [];
  LatLng? userPosition;
  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void goToDetail(Fontanella f) async {
    final needRefresh = await Navigator.pushNamed(
      context,
      '/dettagli_fontanella',
      arguments: f,
    );

    if (needRefresh == true) {
      fetchFontanelle();
    }
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    await fetchUserPosition();
    await fetchFontanelle();
    setState(() => isLoading = false);
  }

  Future<void> fetchUserPosition() async {
    try {
      final position = await LocationHelper.getCurrentPosition();
      if (position == null) {
        return;
      }
      final userLat = position.latitude;
      final userLon = position.longitude;
      setState(() {
        userPosition = LatLng(userLat, userLon);
      });
      if (userPosition != null) {
        _mapController.move(userPosition!, 13.0);
      }
    } catch (e) {
      print('Errore posizione utente: $e');
    }
  }

  Future<void> fetchFontanelle() async {
    final url = '${dotenv.env['API_URL']}/fontanelle';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200 && userPosition != null) {
      final List<dynamic> data = json.decode(response.body);

      final userLat = userPosition!.latitude;
      final userLon = userPosition!.longitude;

      final parsedFontanelle =
          data.map((f) {
            final lat = (f['lat'] as num).toDouble();
            final lon = (f['lon'] as num).toDouble();

            final dist = distance.as(
              LengthUnit.Meter,
              LatLng(userLat, userLon),
              LatLng(lat, lon),
            );

            return Fontanella.fromJson(f, dist);
          }).toList();

      setState(() {
        fontanelle = parsedFontanelle;
      });
    } else {
      print('Errore nel caricamento delle fontanelle');
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter =
        userPosition ?? const LatLng(45.07880889299794, 10.613908277357126);
    return Scaffold(
      body:
          isLoading
              ? const Center(
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [BouncingDotsLoader()],
                  ),
                ),
              )
              : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: userPosition != null ? 14.0 : 7.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.boschetti.splash',
                  ),
                  MarkerLayer(
                    markers: [
                      if (userPosition != null)
                        Marker(
                          point: userPosition!,
                          width: 40,
                          height: 40,
                          child: Transform.translate(
                            offset: const Offset(
                              0,
                              -15,
                            ), // move the icon so the bottom is aligned
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                      ...fontanelle.map(
                        (f) => Marker(
                          point: LatLng(f.lat, f.lon),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => goToDetail(f),
                            child: Transform.translate(
                              offset: const Offset(
                                0,
                                -15,
                              ), // move the icon so the bottom is aligned
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.lightBlue,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}
