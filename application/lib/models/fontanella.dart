import './user.dart';

class Fontanella {
  final String id;
  final String nome;
  final double lat;
  final double lon;
  final double distanza;
  final User? createdBy; // può essere nullo se non presente

  Fontanella({
    required this.id,
    required this.nome,
    required this.lat,
    required this.lon,
    required this.distanza,
    this.createdBy,
  });

  factory Fontanella.fromJson(Map<String, dynamic> json, double distanza) {
    return Fontanella(
      id: json['_id'].toString(),
      nome: json['name'] ?? '-',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      distanza: distanza,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'lat': lat,
      'lon': lon,
      'distanza': distanza,
      'createdBy':
          createdBy != null
              ? {'id': createdBy!.id, 'name': createdBy!.name}
              : null,
    };
  }
}
