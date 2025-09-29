import 'package:application/enum/report_status_enum.dart';
import 'package:application/enum/report_type_enum.dart';

class Report {
  final String id;
  final ReportType type;
  final String value;
  final ReportStatus status;

  Report({
    required this.id,
    required this.type,
    required this.value,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json["id"] ?? json["_id"] ?? "",

      // Se type è un numero
      type:
          (json["type"] is int)
              ? ReportType.values[json["type"]]
              : ReportType.values.firstWhere(
                (e) => e.toString().split('.').last == json["type"].toString(),
                orElse: () => ReportType.values.first,
              ),

      value: json["value"]?.toString() ?? "",

      // Se status è un numero
      status:
          (json["status"] is int)
              ? ReportStatus.values[json["status"]]
              : ReportStatus.values.firstWhere(
                (e) =>
                    e.toString().split('.').last == json["status"].toString(),
                orElse: () => ReportStatus.values.first,
              ),
    );
  }
}
