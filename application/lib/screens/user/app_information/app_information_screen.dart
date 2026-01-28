import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:application/screens/components/minimal_notification.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInformationScreen extends StatefulWidget {
  const AppInformationScreen({super.key});

  @override
  State<AppInformationScreen> createState() => _AppInformationScreenState();
}

class _AppInformationScreenState extends State<AppInformationScreen> {
  bool loading = true;
  String? currentVersion;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
      loading = false;
    });
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showMinimalNotification(
        context,
        message: 'errors.unable_to_open_link'.tr(),
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'app_information'.tr(),
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// APP INFO
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// DEVELOPER
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${'developed_by'.tr()} Matteo Boschetti',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// CONTACT
                  Row(
                    children: [
                      const Icon(Icons.mail, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${'contact_me'.tr()}: mboschetti03@gmail.com',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// VERSION
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${'version'.tr()}: $currentVersion',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// DATA & MAP ATTRIBUTION (IMPORTANT PART)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// OSM ATTRIBUTION
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.public, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _openLink(
                                'https://www.openstreetmap.org/copyright',
                              ),
                              child: Text(
                                '© OpenStreetMap contributors',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () =>
                                  _openLink('https://carto.com/'),
                              child: Text(
                                'Map tiles by CARTO',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// PRIVACY POLICY
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _openLink(
                          '${dotenv.env['API_URI']}/privacy-policy',
                        );
                      },
                      child: Text(
                        'read_privacy_policy'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
