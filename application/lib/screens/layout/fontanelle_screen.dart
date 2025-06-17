import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:application/models/fontanella.dart';
import '../../providers/auth_provider.dart';
import '../../helpers/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FontanelleListScreen extends StatefulWidget {
  const FontanelleListScreen({super.key});

  @override
  State<FontanelleListScreen> createState() => _FontanelleListScreenState();
}

class _FontanelleListScreenState extends State<FontanelleListScreen> {
  // data
  List<Fontanella> fontanelle = [];
  List<Fontanella> filteredFontanelle = [];

  // page controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  // arguments
  String? activeFilter;

  // user session
  bool isUserLogged = false;
  final userSession = UserSession();

  bool isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchFontanelle();
    _checkUserStatus();
    _searchController.addListener(() => filterFontanelle());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nomeController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void filterFontanelle() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredFontanelle = fontanelle;
      } else {
        filteredFontanelle =
            fontanelle
                .where((f) => f.nome.toLowerCase().contains(query))
                .toList();
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
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
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
          if (activeFilter == 'saved_fontanelle') {
            filteredFontanelle = fontanelle.where((f) => f.isSaved).toList();
            fontanelle = fontanelle.where((f) => f.isSaved).toList();
          }
          isLoading = false;
        });
      } else {
        throw Exception('Errore ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() => isLoading = false);
      print('Timeout: il server non ha risposto in tempo.');
    } catch (e) {
      print('Errore nel caricamento: $e');
    }
  }

  void _checkUserStatus() async {
    await AuthHelper.checkLogin();
    setState(() {
      isUserLogged = AuthHelper.isUserLogged;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('filter')) {
      activeFilter = args['filter'];
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

  XFile? _selectedImage;

  void _showAddFontanellaSheet(Position position) {
    _nomeController.clear();
    _latController.text = position.latitude.toStringAsFixed(6);
    _lonController.text = position.longitude.toStringAsFixed(6);
    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome fontanella',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _latController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Latitudine',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _lonController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Longitudine',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Pulsante per caricare immagine
                        ElevatedButton.icon(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setModalState(() {
                                _selectedImage = image;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text("Carica immagine"),
                        ),

                        const SizedBox(height: 12),

                        // Anteprima immagine
                        if (_selectedImage != null)
                          Image.file(
                            File(_selectedImage!.path),
                            height: 150,
                            fit: BoxFit.cover,
                          ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text("Aggiungi fontanella"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submitFontanella,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _submitFontanella() async {
    final nome = _nomeController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());

    if (nome.isEmpty || lat == null || lon == null) {
      showMinimalNotification(context, {
        'message': 'Inserisci il nome!',
        'duration': 2500,
        'position': 'top',
      });
      return;
    }

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/fontanelle'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': nome, 'lat': lat, 'lon': lon}),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
      await fetchFontanelle();
      showMinimalNotification(context, {
        'message': 'Fontanella aggiunta!',
        'duration': 2500,
        'position': 'top',
      });
    } else {
      showMinimalNotification(context, {
        'message': 'Errore!',
        'duration': 2500,
        'position': 'top',
      });
    }
  }

  void showMinimalNotification(
    BuildContext context,
    Map<String, dynamic> options,
  ) {
    final overlay = Overlay.of(context);
    final theme = Theme.of(context);
    final entry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: options['position'] == 'top' ? null : 40,
            top: options['position'] == 'top' ? 40 : null,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      options['backgroundColor'] ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  options['message'] ?? 'Notifica',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: options['textColor'] ?? theme.colorScheme.onSurface,
                    fontSize: options['fontSize']?.toDouble() ?? 14.0,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);

    Future.delayed(
      Duration(milliseconds: options['duration'] ?? 2000),
      () => entry.remove(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Cerca fontanella...',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 20,
                  ),
                )
                : Text(
                  activeFilter == 'saved_fontanelle'
                      ? 'Fontanelle Preferite'
                      : 'Fontanelle Vicine',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
        actions: [
          IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  filteredFontanelle = fontanelle;
                }
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
                    subtitle: Text('${f.distanza.toStringAsFixed(2)} km'),
                    trailing:
                        f.isSaved
                            ? Icon(
                              Icons.bookmark,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                    onTap: () => goToDetail(f),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            isUserLogged
                ? () async {
                  final position = await Geolocator.getCurrentPosition();
                  _showAddFontanellaSheet(position);
                }
                : null,
        backgroundColor:
            isUserLogged ? Theme.of(context).colorScheme.primary : Colors.grey,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
