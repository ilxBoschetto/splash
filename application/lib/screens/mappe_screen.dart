import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MappeScreen extends StatefulWidget {
  const MappeScreen({super.key});

  @override
  State<MappeScreen> createState() => _MappeScreenState();
}

class _MappeScreenState extends State<MappeScreen> {
  List<LatLng> fontanelleCoords = [];

  @override
  void initState() {
    super.initState();
    fetchFontanelle();
  }

  Future<void> fetchFontanelle() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/fontanelle'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Mappa Fontanelle')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
              fontanelleCoords.isNotEmpty
                  ? fontanelleCoords[0]
                  : const LatLng(45.5, 11.5),
          initialZoom: 9.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers:
                fontanelleCoords
                    .map(
                      (coord) => Marker(
                        width: 40,
                        height: 40,
                        point: coord,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
