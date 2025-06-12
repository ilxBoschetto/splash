import './user.dart';

class Fontanella {
  final String id;
  final String nome;
  final double lat;
  final double lon;
  final double distanza;
  final User? createdBy;
  final bool isSaved;
  final String? imageUrl;

  Fontanella({
    required this.id,
    required this.nome,
    required this.lat,
    required this.lon,
    required this.distanza,
    this.createdBy,
    this.isSaved = false,
    this.imageUrl,
  });

  factory Fontanella.fromJson(Map<String, dynamic> json, double distanza) {
    User? createdByUser;

    final createdByData = json['createdBy'];
    if (createdByData != null) {
      if (createdByData is String) {
        createdByUser = User(id: createdByData, name: '-');
      } else if (createdByData is Map<String, dynamic>) {
        createdByUser = User.fromJson(createdByData);
      }
    }

    return Fontanella(
      id: json['_id'].toString(),
      nome: json['name'] ?? '-',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      distanza: distanza,
      createdBy: createdByUser,
      isSaved: json['isSaved'] ?? false,
      imageUrl: json['imageUrl'],
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
      'isSaved': isSaved,
      'imageUrl': imageUrl,
    };
  }
}
