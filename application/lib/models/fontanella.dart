// lib/models/fontanella.dart

class Fontanella {
  final String id;
  final String nome;
  final double lat;
  final double lon;
  final double distanza;

  Fontanella({
    required this.id,
    required this.nome,
    required this.lat,
    required this.lon,
    required this.distanza,
  });

  factory Fontanella.fromJson(Map<String, dynamic> json, double distanza) {
    return Fontanella(
      id: json['id'].toString() ?? 'unknown',
      nome: json['name'] ?? '-',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      distanza: distanza,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'lat': lat,
      'lon': lon,
      'distanza': distanza,
    };
  }
}
