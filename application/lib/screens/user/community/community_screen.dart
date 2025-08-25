import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:application/screens/components/minimal_notification.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  void _openDiscordInvite(BuildContext context) async {
    final url = Uri.parse("https://discord.gg/3tw6qh3t9b");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
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

  void _openBuyMeACoffee(BuildContext context) async {
    final url = Uri.parse("https://buymeacoffee.com/boschetti.splash");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
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
        title: Text('community'.tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              onTap: () => _openDiscordInvite(context),
              leading: const Icon(Icons.discord, color: Colors.indigo),
              title: Text(
                'join_discord'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.open_in_new),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              onTap: () => _openBuyMeACoffee(context),
              leading: const Icon(Icons.coffee, color: Colors.orangeAccent),
              title: Text(
                'buy_me_coffee'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.open_in_new),
            ),
          ),
        ],
      ),
    );
  }
}
