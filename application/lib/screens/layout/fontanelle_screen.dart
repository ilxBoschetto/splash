import 'package:application/enum/potability_enum.dart';
import 'package:application/helpers/fontanella_helper.dart';
import 'package:application/helpers/potability_helper.dart';
import 'package:application/screens/components/fontanella_form.dart';
import 'package:application/screens/components/loaders.dart';
import 'package:application/helpers/auth_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:async';
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
  // Data
  List<Fontanella> fontanelle = [];
  List<Fontanella> filteredFontanelle = [];

  // Pagination
  int _currentPage = 1;
  final int _limit = 100;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  late ScrollController _scrollController;

  // Page controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cittaController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final modalMapController = MapController();
  Potability _potability = Potability.unknown;

  // Arguments
  String? activeFilter;

  // User session
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
    _scrollController = ScrollController()..addListener(_onScroll);
    _initPermissions();
    _checkLocationAndLoad();
    _checkUserStatus();
    _searchController.addListener(() => filterFontanelle());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _nomeController.dispose();
    _cittaController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  // Scroll listener for infinite scroll
  void _onScroll() {
    if (_isFetchingMore || !_hasMore) return;

    // If 25 items from the bottom (approx 1500px)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 1500) {
      fetchFontanelle(isLoadMore: true);
    }
  }

  // Search filter logic
  void filterFontanelle() {
    final query = _searchController.text.toLowerCase();

    List<Fontanella> tempList = fontanelle;

    // Apply 'saved_fontanelle' filter if active
    if (activeFilter == 'saved_fontanelle') {
      tempList = tempList.where((f) => f.isSaved).toList();
    }

    // Apply text search
    if (query.isNotEmpty) {
      tempList =
          tempList.where((f) => f.nome.toLowerCase().contains(query)).toList();
    }

    setState(() {
      filteredFontanelle = tempList;
    });
  }

  // Main data fetching method
  Future<void> fetchFontanelle({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_isFetchingMore || !_hasMore) return;
      setState(() => _isFetchingMore = true);
    } else {
      setState(() {
        isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        fontanelle = [];
      });
    }

    try {
      final position = await LocationHelper.getCurrentPosition();
      final userLat = position?.latitude;
      final userLon = position?.longitude;
      final distance = Distance();

      final response = await FontanellaHelper().fetchFountains(
        lat: userLat,
        lon: userLon,
        page: _currentPage,
        limit: _limit,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Fontanella> loaded = data.map((jsonItem) {
          final lat = jsonItem['lat'].toDouble();
          final lon = jsonItem['lon'].toDouble();
          double dist = 0;
          if (userLat != null && userLon != null) {
            dist = distance.as(
              LengthUnit.Meter,
              LatLng(userLat, userLon),
              LatLng(lat, lon),
            );
          }
          return Fontanella.fromJson(jsonItem, dist);
        }).toList();

        setState(() {
          if (isLoadMore) {
            fontanelle.addAll(loaded);
            _isFetchingMore = false;
          } else {
            fontanelle = loaded;
            isLoading = false;
          }
          
          if (loaded.length < _limit) {
            _hasMore = false;
          } else {
            _currentPage++;
          }
          
          filterFontanelle();
        });
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        isLoading = false;
        _isFetchingMore = false;
      });
      print('errors.server_timeout'.tr());
    } catch (e) {
      setState(() {
        isLoading = false;
        _isFetchingMore = false;
      });
      print('Error loading fountains: $e');
    }
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
    Map<String, dynamic> body = {
        'name': nome,
        'lat': lat,
        'lon': lon,
        'potability': potability.value,
      };
    final response = await FontanellaHelper().createFountain(body);
    if (response.statusCode != 200) {
      String message;
      try {
        final Map<String, dynamic> bodyJson = jsonDecode(response.body);
        message = bodyJson['error']?.toString() ?? 'errors.general_error'.tr();
      } catch (e) {
        message = 'Error: ${response.body}';
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
    await FontanellaHelper().uploadFountainImage(fontanellaId, image);
  }

  Widget _buildStatusIndicator(Fontanella f) {
    final info = PotabilityHelper.getInfo(
      f.potability ?? Potability.unknown,
    );

    return CircleAvatar(
      radius: 12,
      backgroundColor: info.color.withOpacity(0.2),
      child: Icon(info.icon, size: 16, color: info.color),
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
                    hintText: '${'drinking_fountain'.tr()}...',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
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
      ),
      body:
          isLoading
              ? const FountainListSkeleton(itemCount: 15)
              : !isLocationEnabled
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'position_disabled'.tr(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasLocationPermission
                          ? 'position_disabled_message'.tr()
                          : 'position_permission_required'.tr(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: Text(
                        hasLocationPermission
                            ? 'open_settings'.tr()
                            : 'grant_permissions'.tr(),
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
                controller: _scrollController,
                itemCount: filteredFontanelle.length + (_isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredFontanelle.length) {
                    return const FountainSkeleton();
                  }

                  final f = filteredFontanelle[index];

                  return Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () => goToDetail(f),
                      child: InkWell(
                        onTap: () => goToDetail(f),
                        child: ListTile(
                          leading: _buildStatusIndicator(f),
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
