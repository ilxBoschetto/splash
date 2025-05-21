import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:application/models/fontanella.dart';

class FontanelleListScreen extends StatefulWidget {
  const FontanelleListScreen({super.key});

  @override
  State<FontanelleListScreen> createState() => _FontanelleListScreenState();
}

class _FontanelleListScreenState extends State<FontanelleListScreen> {
  List<Fontanella> fontanelle = [];
  List<Fontanella> filteredFontanelle = [];
  bool isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFontanelle();

    _searchController.addListener(() {
      filterFontanelle();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterFontanelle() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredFontanelle = fontanelle;
      } else {
        filteredFontanelle =
            fontanelle.where((f) {
              return f.nome.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  Future<void> fetchFontanelle() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final userLat = position.latitude;
      final userLon = position.longitude;
      final distance = Distance();

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/fontanelle'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Fontanella> loaded =
            data.map((jsonItem) {
              final lat = jsonItem['lat'].toDouble();
              final lon = jsonItem['lon'].toDouble();
              final dist = distance.as(
                LengthUnit.Kilometer,
                LatLng(userLat, userLon),
                LatLng(lat, lon),
              );
              return Fontanella.fromJson(jsonItem, dist);
            }).toList();

        loaded.sort((a, b) => a.distanza.compareTo(b.distanza));

        setState(() {
          fontanelle = loaded;
          filteredFontanelle = loaded;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Errore nel caricamento: $e');
    }
  }

  void goToDetail(Fontanella f) {
    Navigator.pushNamed(context, '/dettagli_fontanella', arguments: f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Cerca fontanella...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                )
                : const Text('Fontanelle vicine'),
        actions: [
          _isSearching
              ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    filteredFontanelle = fontanelle;
                  });
                },
              )
              : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: filteredFontanelle.length,
                itemBuilder: (context, index) {
                  final f = filteredFontanelle[index];
                  return ListTile(
                    title: Text(f.nome),
                    subtitle: Text('${f.distanza} km'),
                    onTap: () => goToDetail(f),
                  );
                },
              ),
    );
  }
}
