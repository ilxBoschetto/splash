import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Impostazioni Utente')),
      body: Center(child: Text('Profilo e impostazioni')),
    );
  }
}
