import 'package:flutter/material.dart';
import 'package:application/models/fontanella.dart';
import 'package:url_launcher/url_launcher.dart';

class FontanellaDetailScreen extends StatelessWidget {
  const FontanellaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Fontanella fontanella =
        ModalRoute.of(context)!.settings.arguments as Fontanella;

    return Scaffold(
      appBar: AppBar(title: Text(fontanella.nome)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Immagine a sinistra
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Informazioni a destra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latitudine: ${fontanella.lat}'),
                      Text('Longitudine: ${fontanella.lon}'),
                      Text(
                        'Distanza: ${fontanella.distanza.toStringAsFixed(2)} km',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Pulsante Google Maps
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _openInMaps(fontanella.lat, fontanella.lon);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Apri in Google Maps'),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps(double lat, double lon) async {
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossibile aprire Google Maps';
    }
  }

}
