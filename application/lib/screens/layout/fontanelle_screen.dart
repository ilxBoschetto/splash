import 'package:application/enum/potability_enum.dart';
import 'package:application/screens/components/fontanella_form.dart';
import 'package:application/screens/components/loaders.dart';
import 'package:application/helpers/auth_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:application/models/fontanella.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../helpers/location_helper.dart';
import '../../helpers/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application/screens/components/minimal_notification.dart';

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
  final TextEditingController _cittaController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final modalMapController = MapController();
  Potability _potability = Potability.unknown;

  // arguments
  String? activeFilter;

  // user session
  bool isUserLogged = false;
  final ValueNotifier<bool> _isSubmitting = ValueNotifier(false);
  final userSession = UserSession();

  bool isLoading = true;
  bool isLocationEnabled = true;
  bool hasLocationPermission = false;
  bool _isSearching = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    _checkLocationAndLoad();
    _checkUserStatus();
    _searchController.addListener(() => filterFontanelle());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nomeController.dispose();
    _cittaController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void filterFontanelle() {
    _searchController.text = _searchController.text.toString();
    final query = _searchController.text.toLowerCase();

    List<Fontanella> tempList = fontanelle;

    // Applica filtro 'saved_fontanelle' se attivo
    if (activeFilter == 'saved_fontanelle') {
      tempList = tempList.where((f) => f.isSaved).toList();
    }

    // Applica ricerca testuale
    if (query.isNotEmpty) {
      tempList =
          tempList.where((f) => f.nome.toLowerCase().contains(query)).toList();
    }

    setState(() {
      filteredFontanelle = tempList;
    });
  }

  Future<void> _initPermissions() async {
    final granted = await checkLocationPermission();
    setState(() {
      hasLocationPermission = granted;
    });
  }

  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<void> _checkLocationAndLoad() async {
    setState(() {
      isLoading = true;
    });

    final serviceEnabled = await LocationHelper.isServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLocationEnabled = false;
        isLoading = false;
      });
      return;
    }

    final hasPermission = await LocationHelper.checkAndRequestPermission();
    if (!hasPermission) {
      setState(() {
        isLocationEnabled = false;
        isLoading = false;
      });
      return;
    }

    await fetchFontanelle();
  }

  Future<void> fetchFontanelle() async {
    try {
      final position = await LocationHelper.getCurrentPosition();
      if (position == null) {
        return;
      }
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
              double dist = distance.as(
                LengthUnit.Meter,
                LatLng(userLat, userLon),
                LatLng(lat, lon),
              );
              return Fontanella.fromJson(jsonItem, dist);
            }).toList();

        loaded.sort((a, b) => a.distanza.compareTo(b.distanza));

        setState(() {
          fontanelle = loaded;
          filterFontanelle();
          isLoading = false;
        });
      } else {
        throw Exception('Errore ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() => isLoading = false);
      print('errors.server_timeout'.tr());
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
      filterFontanelle();
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
    _cittaController.clear();
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
          (ctx) => Theme(
            data: Theme.of(ctx),
            child: FountainForm(
              nomeController: _nomeController,
              cittaController: _cittaController,
              latController: _latController,
              lonController: _lonController,
              isSubmitting: _isSubmitting,
              initialPosition: LatLng(position.latitude, position.longitude),
              mapController: modalMapController,
              onSubmit: _submitFontanella,
              onImagePicked: (img) => _selectedImage = img,
              onPotabilityChanged: (p) => setState(() => _potability = p),
            ),
          ),
    );
  }

  Future<void> _submitFontanella() async {
    _isSubmitting.value = true;
    try {
      String nome = _nomeController.text.trim();
      final lat = double.tryParse(_latController.text.trim());
      final lon = double.tryParse(_lonController.text.trim());

      if (nome.isEmpty || lat == null || lon == null) {
        showMinimalNotification(
          context,
          message: 'warnings.insert_name'.tr(),
          duration: 2500,
          position: 'top',
          backgroundColor: Colors.orange,
        );
        _isSubmitting.value = false;
        return;
      }

      if (_cittaController.text.trim().isNotEmpty) {
        nome += " - ${_cittaController.text.trim()}";
      }

      await inviaFontanella(
        nome: nome,
        lat: lat,
        lon: lon,
        image: _selectedImage,
        potability: _potability,
      );
    } finally {
      if (mounted) {
        _isSubmitting.value = false;
      }
    }
  }

  Future<void> inviaFontanella({
    required String nome,
    required double lat,
    required double lon,
    XFile? image,
    required Potability potability,
  }) async {
    final uri = Uri.parse('${dotenv.env['API_URL']}/fontanelle');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': nome,
        'lat': lat,
        'lon': lon,
        'potability': _potability.value,
      }),
    );

    if (response.statusCode != 200) {
      String message;
      try {
        final Map<String, dynamic> bodyJson = jsonDecode(response.body);
        message = bodyJson['error']?.toString() ?? 'errors.general_error'.tr();
      } catch (e) {
        message = 'Errore: ${response.body}';
      }
      showMinimalNotification(
        context,
        message: message,
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.red,
      );
    } else {
      if (image != null) {
        final fontanellaId = jsonDecode(response.body)['_id'];
        inviaFontanellaImage(fontanellaId, image);
      }
      Navigator.of(context).pop();
      await fetchFontanelle();
      showMinimalNotification(
        context,
        message: 'drinking_fountain.added_action'.tr(),
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.green,
      );
    }
  }

  Future<void> inviaFontanellaImage(String fontanellaId, XFile? image) async {
    final uri = Uri.parse(
      '${dotenv.env['API_URL']}/fontanelle/$fontanellaId/image',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${userSession.token}';
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print(jsonDecode(response.body));
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
                    hintText: '${'drinking_fountain'.tr()}...',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
                : Text(
                  activeFilter == 'saved_fontanelle'
                      ? 'drinking_fountain.saved'.tr()
                      : 'drinking_fountain.near'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
        /*
        actions: [
          IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  filterFontanelle();
                }
              });
            },
          ),
        ],
        */
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : !isLocationEnabled
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'position_disabled'.tr(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasLocationPermission
                          ? 'position_disabled_message'.tr()
                          : 'position_permission_required'
                              .tr(), // nuovo messaggio
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: Text(
                        hasLocationPermission
                            ? 'open_settings'.tr()
                            : 'grant_permissions'.tr(), // testo bottone diverso
                      ),
                      onPressed: () {
                        if (hasLocationPermission) {
                          LocationHelper.openLocationSettings();
                        } else {
                          openAppSettings();
                        }
                      },
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: filteredFontanelle.length,
                itemBuilder: (context, index) {
                  final f = filteredFontanelle[index];

                  return Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () => goToDetail(f),
                      child: InkWell(
                        onTap: () => goToDetail(f), // per il ripple
                        child: ListTile(
                          title: Text(f.nome),
                          subtitle: Text(
                            LocationHelper.formatDistanza(f.distanza),
                          ),
                          trailing:
                              f.isSaved
                                  ? Icon(
                                    Icons.bookmark,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            isUserLogged && !_isAdding
                ? () async {
                  setState(() {
                    _isAdding = true;
                  });

                  try {
                    final position = await LocationHelper.getCurrentPosition();
                    if (position == null) {
                      return;
                    }
                    _showAddFontanellaSheet(position);
                  } finally {
                    setState(() {
                      _isAdding = false;
                    });
                  }
                }
                : null,
        backgroundColor:
            isUserLogged ? Theme.of(context).colorScheme.primary : Colors.grey,
        child:
            _isAdding
                ? const Center(child: BouncingDotsLoader(dotSize: 8))
                : const Icon(Icons.add, size: 28),
      ),
    );
  }
}
