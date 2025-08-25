import 'package:application/app_layout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckWrapper extends StatefulWidget {
  const VersionCheckWrapper({super.key});

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkAppVersion();
      if (!mounted) return;

      // Naviga solo se nessun aggiornamento obbligatorio o l'utente ha scelto di proseguire
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppLayout()),
      );
    });
  }

  Future<void> checkAppVersion() async {
    final String apiUrl = dotenv.env['APP_VERSION_CHECK_URL'] ?? '';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      print('Current version: $currentVersion');
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String latestVersion = data['latestVersion'];
        String minSupportedVersion = data['minSupportedVersion'];
        String playStoreUrl = data['playStoreUrl'];

        if (!mounted) return;

        if (_isVersionLower(currentVersion, minSupportedVersion)) {
          // Aggiornamento obbligatorio: blocca il flusso finché l'utente non aggiorna
          await _showUpdateDialog(
            context,
            mandatory: true,
            url: playStoreUrl,
          );
        } else if (_isVersionLower(currentVersion, latestVersion)) {
          // Aggiornamento opzionale: mostra dialog, ma non blocca
          await _showUpdateDialog(
            context,
            mandatory: false,
            url: playStoreUrl,
          );
        }
      } else {
        print('Errore nella chiamata: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore nella richiesta: $e');
    }
  }

  bool _isVersionLower(String current, String target) {
    final currentParts = current.split('.').map(int.parse).toList();
    final targetParts = target.split('.').map(int.parse).toList();

    for (int i = 0; i < targetParts.length; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final targetPart = targetParts[i];

      if (currentPart < targetPart) return true;
      if (currentPart > targetPart) return false;
    }
    return false;
  }

  Future<void> _showUpdateDialog(BuildContext context,
      {required bool mandatory, required String url}) {
    return showDialog(
      context: context,
      barrierDismissible: !mandatory,
      builder: (context) {
        return PopScope(
          canPop: !mandatory,
          child: AlertDialog(
            title: Text('update_available'.tr()),
            content: Text(
              mandatory
                  ? 'mandatory_update_message'.tr()
                  : 'available_update_message'.tr(),
            ),
            actions: [
              if (!mandatory)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('later'.tr()),
                ),
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    print('Impossibile aprire l\'URL');
                  }
                  if (mandatory) {
                    // Dopo aver aperto il link in caso obbligatorio, chiudi app o resta bloccato
                    // oppure mantieni il dialog aperto, scegli tu
                  }
                },
                child: Text('general.update'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
