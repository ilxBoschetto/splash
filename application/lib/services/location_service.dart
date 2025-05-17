import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se il GPS è attivo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servizi di localizzazione disattivati.');
    }

    // Verifica e richiedi permessi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permesso di localizzazione negato.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permesso negato in modo permanente.');
    }

    // Ottieni la posizione
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
