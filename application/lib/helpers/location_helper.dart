import 'package:geolocator/geolocator.dart';

class LocationHelper {
  /// Controlla se i servizi di localizzazione sono abilitati
  static Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Richiede i permessi di localizzazione se necessari
  /// Restituisce `true` se i permessi sono concessi, `false` altrimenti
  static Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Return the current location
  static Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) return null;

    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition();
  }

  // Open device settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
