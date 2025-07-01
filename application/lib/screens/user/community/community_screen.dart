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
          message: 'Impossibile aprire il link discord',
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
        title: const Text('Community'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              onTap: () => _openDiscordInvite(context),
              leading: const Icon(Icons.discord, color: Colors.indigo),
              title: const Text(
                'Unisciti al server Discord',
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
