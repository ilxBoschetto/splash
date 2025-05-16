import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FontanelleListScreen extends StatefulWidget {
  const FontanelleListScreen({super.key});

  @override
  State<FontanelleListScreen> createState() => _FontanelleListScreenState();
}

class _FontanelleListScreenState extends State<FontanelleListScreen> {
  List<dynamic> fontanelle = [];

  @override
  void initState() {
    super.initState();
    fetchFontanelle();
  }

  Future<void> fetchFontanelle() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/fontanelle'));

    if (response.statusCode == 200) {
      setState(() {
        fontanelle = json.decode(response.body);
      });
    } else {
      // error handling
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fontanelle')),
      body: ListView.builder(
        itemCount: fontanelle.length,
        itemBuilder: (context, index) {
          final f = fontanelle[index];
          return ListTile(
            title: Text(f['name']),
            subtitle: Text('Lat: ${f['lat']}, Lon: ${f['lon']}'),
          );
        },
      ),
    );
  }
}
