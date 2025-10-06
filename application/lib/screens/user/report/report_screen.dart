import 'dart:convert';
import 'dart:ui'; // per BackdropFilter
import 'package:application/enum/potability_enum.dart';
import 'package:application/enum/report_status_enum.dart';
import 'package:application/enum/report_type_enum.dart';
import 'package:application/helpers/potability_helper.dart';
import 'package:application/helpers/user_session.dart';
import 'package:application/models/report.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReportScreen extends StatefulWidget {
  final bool isAdmin;
  const ReportScreen({super.key, this.isAdmin = false});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Report> reports = [];
  bool loading = true;
  final userSession = UserSession();

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final uri = '${dotenv.env['API_URL']}/reports';

      final res = await http.get(
        Uri.parse(uri),
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body)["reports"];
        final items = data.map((e) => Report.fromJson(e)).toList();

        // ordinamento custom
        items.sort((a, b) {
          int order(ReportStatus s) {
            switch (s) {
              case ReportStatus.pending:
                return 0;
              case ReportStatus.rejected:
                return 1;
              case ReportStatus.accepted:
                return 2;
            }
          }

          return order(a.status).compareTo(order(b.status));
        });

        setState(() {
          reports = items;
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _updateReportStatus(String id, ReportStatus newStatus) async {
    final url =
        '${dotenv.env['API_URL']}/reports/$id/${newStatus == ReportStatus.accepted ? "accept" : "reject"}';
    final res = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      _fetchReports();
    }
  }

  Color _statusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return const Color.fromARGB(255, 52, 51, 51).withOpacity(0.25);
      case ReportStatus.rejected:
        return const Color.fromARGB(255, 167, 107, 102).withOpacity(0.10);
      case ReportStatus.accepted:
        return const Color.fromARGB(255, 159, 199, 161).withOpacity(0.10);
    }
  }

  Widget _buildReportDetails(Report report) {
    switch (report.type) {
      case ReportType.wrongInformation:
        return Text("Dettagli: ${report.value}");
      case ReportType.wrongImage:
        return Image.network(report.value);
      case ReportType.nonExistentFontanella:
        return const Text(
          "La fontanella segnalata non esiste.",
          style: TextStyle(fontStyle: FontStyle.italic),
        );
      case ReportType.wrongPotability:
        final int potabilityIndex =
            int.tryParse(report.value) ?? Potability.unknown.index;
        final info = PotabilityHelper.getInfo(
          Potability.values[potabilityIndex],
        );
        return Row(
          children: [
            Icon(info.icon, color: info.color),
            const SizedBox(width: 8),
            Text(info.label, style: const TextStyle(fontSize: 16)),
          ],
        );
    }
  }

  Widget _buildReportCard(Report report) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _statusColor(report.status),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              // testo report
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${"${DateFormat('dd/MM').format(report.createdAt)} - ${report.type.translationKey.tr()}"} - ${report.fountain != null ? report.fountain!.name : "Fontanella rimossa"}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white70,
                        decoration:
                            report.status != ReportStatus.pending
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(report.updatedAt),
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 9,
                        color: Colors.white70,
                        decoration:
                            report.status != ReportStatus.pending
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (report.status == ReportStatus.pending)
                      _buildReportDetails(report),
                  ],
                ),
              ),

              if (userSession.isAdmin == true &&
                  report.status == ReportStatus.pending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed:
                          () => _updateReportStatus(
                            report.id,
                            ReportStatus.rejected,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed:
                          () => _updateReportStatus(
                            report.id,
                            ReportStatus.accepted,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('reports.my_reports'.tr())),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : reports.isEmpty
              ? const Center(child: Text("Nessun report trovato"))
              : ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return _buildReportCard(report);
                },
              ),
    );
  }
}
