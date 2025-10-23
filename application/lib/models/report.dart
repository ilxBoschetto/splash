import 'package:application/enum/report_status_enum.dart';
import 'package:application/enum/report_type_enum.dart';
import './fontanella.dart';

class Report {
  final String id;
  final ReportType type;
  final String? value;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Fontanella? fontanella;
  final dynamic originalValue; // può essere stringa o mappa

  Report({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.value,
    this.fontanella,
    this.originalValue,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    // Parsing tipo
    final ReportType type = () {
      final t = json['type'];
      if (t is int) {
        return ReportType.values[t.clamp(0, ReportType.values.length - 1)];
      } else if (t is String) {
        return ReportType.values.firstWhere(
          (e) => e.name == t,
          orElse: () => ReportType.values.first,
        );
      }
      return ReportType.values.first;
    }();

    // Parsing stato
    final ReportStatus status = () {
      final s = json['status'];
      if (s is int) {
        return ReportStatus.values[s.clamp(0, ReportStatus.values.length - 1)];
      } else if (s is String) {
        return ReportStatus.values.firstWhere(
          (e) => e.name == s,
          orElse: () => ReportStatus.values.first,
        );
      }
      return ReportStatus.values.first;
    }();

    Fontanella? fontanella;
    if (json['fontanella'] is Map<String, dynamic>) {
      fontanella = Fontanella.fromJson(json['fontanella'], 0.0);
    }

    final dynamic originalValue =
        json.containsKey('originalValue') ? json['originalValue'] : null;

    return Report(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: type,
      status: status,
      value: json['value']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      fontanella: fontanella,
      originalValue: originalValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fontanella': fontanella?.toJson(),
      'originalValue': originalValue,
    };
  }
}
