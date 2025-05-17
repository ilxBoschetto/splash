import 'package:flutter/material.dart';

class FontanelleListScreen extends StatelessWidget {
  const FontanelleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fontanelle')),
      body: Center(child: Text('Lista delle fontanelle')),
    );
  }
}
