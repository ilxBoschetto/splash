import 'package:application/models/fontanella.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MappeScreen extends StatefulWidget {
  const MappeScreen({super.key});

  @override
  State<MappeScreen> createState() => _MappeScreenState();
}

class _MappeScreenState extends State<MappeScreen> {
  final MapController _mapController = MapController();
  List<Fontanella> fontanelle = [];
  LatLng? userPosition;
  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    loadCachedUserPosition(); // carica posizione dalla cache se disponibile
    fetchData();
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

  Future<void> cacheUserPosition(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cached_lat', position.latitude);
    await prefs.setDouble('cached_lon', position.longitude);
  }

  Future<void> fetchData() async {
    await fetchUserPosition();
    await fetchFontanelle();
  }

  Future<void> fetchUserPosition() async {
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        userPosition = LatLng(position.latitude, position.longitude);
      });
      await cacheUserPosition(position); // salva in cache
      if (userPosition != null) {
        _mapController.move(userPosition!, 14.0);
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

      final parsedFontanelle = data.map((f) {
        final lat = (f['lat'] as num).toDouble();
        final lon = (f['lon'] as num).toDouble();
        final dist = distance.as(
          LengthUnit.Kilometer,
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
        userPosition ?? const LatLng(45.72064772402749, 11.309933083088417);
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: initialCenter, initialZoom: 14.0),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName:
                'com.splash.app',
          ),
          MarkerLayer(
            markers: [
              if (userPosition != null)
                Marker(
                  point: userPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
              ...fontanelle.map(
                (f) => Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(f.lat, f.lon),
                  child: GestureDetector(
                    onTap: () => goToDetail(f),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.lightBlue,
                      size: 30,
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
