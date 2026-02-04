import 'dart:async';

import 'package:application/helpers/fontanella_helper.dart';
import 'package:application/screens/components/loaders.dart';
import 'package:application/helpers/location_helper.dart';
import 'package:application/models/fontanella.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
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
  Timer? _debounce;
  List<Fontanella> allFontanelle = [];
  List<Marker> _allMarkers = [];
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

  Future<void> fetchMarkers() async{
    _allMarkers =
    // use fontanelle to create filtered markers
      fontanelle.map((f) {
        return Marker(
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
        );
      }).toList();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    await fetchUserPosition();
    await fetchFontanelle();
    await fetchMarkers();
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
    final response = await FontanellaHelper().fetchFountains();

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
        allFontanelle = parsedFontanelle;
        fontanelle = parsedFontanelle;
      });
    } else {
      print('Errore nel caricamento delle fontanelle');
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _normalize(query.trim());
      if (q.isEmpty) {
        setState(() => fontanelle = List<Fontanella>.from(allFontanelle));
        return;
      }

      final results =
          allFontanelle.where((f) {
            final nome = _normalize(f.nome);
            return nome.contains(q);
          }).toList();

      setState(() => fontanelle = results);
      fetchFontanelle();
      fetchMarkers();
    });
  }

  String _normalize(String s) {
    var lower = s.toLowerCase();
    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };
    accents.forEach((k, v) {
      lower = lower.replaceAll(k, v);
    });
    return lower;
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void centerUser() async {
    if (userPosition == null) {
      await fetchUserPosition();
    }

    if (userPosition == null) return;

    _mapController.move(userPosition!, 14.0);
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter =
        userPosition ?? LatLng(41.9028, 12.4964); // Rome coordinates as default
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
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: userPosition != null ? 14.0 : 7.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: 'com.boschetti.splash',
                      ),
                      MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        markers: _allMarkers,
                        maxClusterRadius: 80,
                        size: const Size(40, 40),
                        builder: (context, markers) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                markers.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )

                    ],
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 16,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "general.search".tr(),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.55),
                                    fontSize: 15,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 0,
                                  ),
                                ),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                cursorColor:
                                    Theme.of(context).colorScheme.primary,
                                onChanged: onSearchChanged,
                              ),
                            ),
                            const SizedBox(width: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Column(
                          children: [
                            _buildControlButton(
                              context,
                              icon: Icons.my_location,
                              onTap: () {
                                centerUser();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
