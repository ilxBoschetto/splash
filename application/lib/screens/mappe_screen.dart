import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MappeScreen extends StatefulWidget {
  const MappeScreen({super.key});

  @override
  State<MappeScreen> createState() => _MappeScreenState();
}

class _MappeScreenState extends State<MappeScreen> {
  List<LatLng> fontanelleCoords = [];
  LatLng? userPosition;

  @override
  void initState() {
    super.initState();
    fetchData();
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
    } catch (e) {
      print('Errore posizione utente: $e');
    }
  }

  Future<void> fetchFontanelle() async {
    final url = '${dotenv.env['API_URL']}/fontanelle';
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        fontanelleCoords =
            data
                .map((f) => LatLng(f['lat'].toDouble(), f['lon'].toDouble()))
                .toList();
      });
    } else {
      print('Errore nel caricamento delle fontanelle');
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = userPosition ?? const LatLng(45.5, 11.5);
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: 9.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            
            markers:[
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

                ...fontanelleCoords
                    .map(
                      (coord) => Marker(
                        width: 40,
                        height: 40,
                        point: coord,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.lightBlue,
                          size: 30,
                        ),
                      ),
                    )
                    ,
            ]
                
          ),
        ],
      ),
    );
  }
}
