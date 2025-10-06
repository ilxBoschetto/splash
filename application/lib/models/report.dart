import 'package:application/enum/report_status_enum.dart';
import 'package:application/enum/report_type_enum.dart';

class Fountain {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final String stato;

  Fountain({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.stato,
  });

  factory Fountain.fromJson(Map<String, dynamic> json) {
    return Fountain(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      lat: (json["lat"] as num?)?.toDouble() ?? 0.0,
      lon: (json["lon"] as num?)?.toDouble() ?? 0.0,
      stato: json["stato"] ?? "",
    );
  }
}

class Report {
  final String id;
  final ReportType type;
  final String value;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Fountain? fountain;

  Report({
    required this.id,
    required this.type,
    required this.value,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fountain,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    // parsing type
    ReportType type;
    if (json["type"] is int) {
      type = ReportType.values[json["type"]];
    } else {
      type = ReportType.values.firstWhere(
        (e) => e.toString().split('.').last == json["type"].toString(),
        orElse: () => ReportType.values.first,
      );
    }

    // parsing status
    ReportStatus status;
    if (json["status"] is int) {
      status = ReportStatus.values[json["status"]];
    } else {
      status = ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json["status"].toString(),
        orElse: () => ReportStatus.values.first,
      );
    }

    return Report(
      id: json["id"] ?? json["_id"] ?? "",
      type: type,
      value: json["value"]?.toString() ?? "",
      status: status,
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      fountain:
          json["fontanella"] != null
              ? Fountain.fromJson(json["fontanella"])
              : null,
    );
  }
}
