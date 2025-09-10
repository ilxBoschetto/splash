import 'dart:io';
import 'package:application/enum/potability_enum.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import './loaders.dart';

class FountainForm extends StatefulWidget {
  final TextEditingController nomeController;
  final TextEditingController cittaController;
  final TextEditingController latController;
  final TextEditingController lonController;
  final ValueNotifier<bool> isSubmitting;
  final LatLng initialPosition;
  final MapController mapController;
  final Future<void> Function()? onSubmit;
  final void Function(XFile? image)? onImagePicked;
  final void Function(Potability)? onPotabilityChanged;

  const FountainForm({
    super.key,
    required this.nomeController,
    required this.cittaController,
    required this.latController,
    required this.lonController,
    required this.isSubmitting,
    required this.initialPosition,
    required this.mapController,
    required this.onImagePicked,
    this.onSubmit,
    this.onPotabilityChanged,
  });

  @override
  State<FountainForm> createState() => _FountainFormState();
}

class _FountainFormState extends State<FountainForm> {
  XFile? _selectedImage;
  late LatLng _mapCenter;

  // Evita feedback loop tra mappa e campi testo
  bool _updatingFromMap = false;
  bool _updatingFromText = false;
  Potability potability = Potability.unknown;

  @override
  void initState() {
    super.initState();
    _mapCenter = widget.initialPosition;

    // Listener SOLO qui (non in build) + saranno rimossi in dispose
    widget.latController.addListener(_updateMapCenterFromText);
    widget.lonController.addListener(_updateMapCenterFromText);
  }

  @override
  void didUpdateWidget(covariant FountainForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se i controller vengono sostituiti dal parent, riallaccia i listener
    if (oldWidget.latController != widget.latController) {
      oldWidget.latController.removeListener(_updateMapCenterFromText);
      widget.latController.addListener(_updateMapCenterFromText);
    }
    if (oldWidget.lonController != widget.lonController) {
      oldWidget.lonController.removeListener(_updateMapCenterFromText);
      widget.lonController.addListener(_updateMapCenterFromText);
    }
  }

  @override
  void dispose() {
    // Rimuovi i listener (i controller sono del parent → non fare dispose)
    widget.latController.removeListener(_updateMapCenterFromText);
    widget.lonController.removeListener(_updateMapCenterFromText);
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (image != null) {
      setState(() => _selectedImage = image);
      widget.onImagePicked?.call(image); // <-- notifica al parent
    }
  }

  void _updateMapCenterFromText() {
    if (_updatingFromMap) return; // stiamo aggiornando dai movimenti mappa
    final lat = double.tryParse(widget.latController.text);
    final lon = double.tryParse(widget.lonController.text);
    if (lat == null || lon == null) return;

    final newCenter = LatLng(lat, lon);
    if (newCenter == _mapCenter) return;

    _updatingFromText = true;
    if (!mounted) {
      _updatingFromText = false;
      return;
    }
    setState(() {
      _mapCenter = newCenter;
    });

    // Muovi la mappa al frame successivo (evita chiamate durante smontaggio)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.mapController.move(_mapCenter, widget.mapController.camera.zoom);
      _updatingFromText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mediaQuery = MediaQuery.of(context);
    final bottomPadding =
        mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding > 20 ? bottomPadding : 20,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.nomeController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'drinking_fountain.name'.tr(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: TextField(
                    controller: widget.cittaController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'drinking_fountain.city'.tr(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: SizedBox(), // campo vuoto per futuri input
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.latController,
                    style: theme.textTheme.bodyMedium,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'drinking_fountain.latitude'.tr(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: widget.lonController,
                    style: theme.textTheme.bodyMedium,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'drinking_fountain.longitude'.tr(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  Potability.values.map((p) {
                    Color color;
                    IconData icon;
                    String label;

                    switch (p) {
                      case Potability.potable:
                        color = Colors.lightBlue;
                        icon = Icons.invert_colors;
                        label = 'drinking_fountain.potable'.tr();
                        break;
                      case Potability.notPotable:
                        color = Colors.orange;
                        icon = Icons.invert_colors_off;
                        label = 'drinking_fountain.not_potable'.tr();
                        break;
                      case Potability.unknown:
                        color = Colors.grey;
                        icon = Icons.invert_colors;
                        label = 'drinking_fountain.unknown'.tr();
                        break;
                    }

                    final bool selected = potability == p;

                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => potability = p);
                          if (widget.onPotabilityChanged != null) {
                            widget.onPotabilityChanged!(p);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? color.withOpacity(0.2)
                                    : theme.inputDecorationTheme.fillColor ??
                                        Colors.white,
                            border: Border.all(
                              color:
                                  theme
                                      .inputDecorationTheme
                                      .enabledBorder
                                      ?.borderSide
                                      .color ??
                                  Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(icon, color: color),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text('drinking_fountain.upload_image'.tr()),
              ),
            ),

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.file(
                  File(_selectedImage!.path),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: widget.mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: 17,
                    onPositionChanged: (pos, hasGesture) {
                      if (!mounted || pos.center == null) return;

                      if (_updatingFromText) return;

                      final c = pos.center!;
                      if (c == _mapCenter) return;

                      _updatingFromMap = true;
                      setState(() {
                        _mapCenter = c;
                        widget.latController.text = c.latitude.toStringAsFixed(
                          6,
                        );
                        widget.lonController.text = c.longitude.toStringAsFixed(
                          6,
                        );
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updatingFromMap = false;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.boschetti.splash',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _mapCenter,
                          width: 40,
                          height: 40,
                          child: Transform.translate(
                            offset: const Offset(
                              0,
                              -15,
                            ), // sposta l’icona verso l’alto
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: widget.isSubmitting,
              builder: (context, isSubmitting, _) {
                return ElevatedButton.icon(
                  onPressed: isSubmitting ? null : widget.onSubmit,
                  icon: const Icon(Icons.add_location_alt),
                  label:
                      isSubmitting
                          ? const SizedBox(
                            height: 20,
                            child: BouncingDotsLoader(),
                          )
                          : Text('drinking_fountain.add'.tr()),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
