import 'package:flutter/material.dart';
import 'package:application/models/fontanella.dart';

class FontanellaDetailScreen extends StatelessWidget {
  const FontanellaDetailScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final Fontanella fontanella = ModalRoute.of(context)!.settings.arguments as Fontanella;

    return Scaffold(
      appBar: AppBar(title: Text(fontanella.nome)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitudine: ${fontanella.lat}'),
            Text('Longitudine: ${fontanella.lon}'),
            Text('Distanza: ${fontanella.distanza.toStringAsFixed(2)} km'),
          ],
        ),
      ),
    );
  }
}