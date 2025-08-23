import 'dart:io';
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

  const FountainForm({
    super.key,
    required this.nomeController,
    required this.cittaController,
    required this.latController,
    required this.lonController,
    required this.isSubmitting,
    required this.initialPosition,
    required this.mapController,
    this.onSubmit,
  });

  @override
  State<FountainForm> createState() => _FountainFormState();
}

class _FountainFormState extends State<FountainForm> {
  XFile? _selectedImage;
  late LatLng _mapCenter;

  @override
  void initState() {
    super.initState();
    _mapCenter = widget.initialPosition;
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _updateMapCenterFromText() {
    final lat = double.tryParse(widget.latController.text);
    final lon = double.tryParse(widget.lonController.text);
    if (lat != null && lon != null) {
      setState(() => _mapCenter = LatLng(lat, lon));
      widget.mapController.move(_mapCenter, widget.mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.latController.addListener(_updateMapCenterFromText);
    widget.lonController.addListener(_updateMapCenterFromText);

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
          children: [
            TextField(
              controller: widget.nomeController,
              decoration: const InputDecoration(labelText: 'Nome fontanella'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: widget.cittaController,
              decoration: const InputDecoration(labelText: 'Città'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.latController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Latitudine'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: widget.lonController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Longitudine'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Carica immagine"),
            ),
            if (_selectedImage != null)
              Image.file(
                File(_selectedImage!.path),
                height: 150,
                fit: BoxFit.cover,
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
                    onPositionChanged: (MapPosition pos, bool hasGesture) {
                      if (hasGesture && pos.center != null) {
                        setState(() {
                          _mapCenter = pos.center!;
                          widget.latController.text = _mapCenter.latitude
                              .toStringAsFixed(6);
                          widget.lonController.text = _mapCenter.longitude
                              .toStringAsFixed(6);
                        });
                      }
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
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.red,
                            size: 40,
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
              builder: (context, isSubmitting, child) {
                return ElevatedButton.icon(
                  onPressed: isSubmitting ? null : widget.onSubmit,
                  icon: const Icon(Icons.add_location_alt),
                  label:
                      isSubmitting
                          ? const SizedBox(
                            height: 20,
                            child: BouncingDotsLoader(),
                          )
                          : const Text("Aggiungi fontanella"),
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
