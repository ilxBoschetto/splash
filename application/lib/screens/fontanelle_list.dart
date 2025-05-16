import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_layout.dart';

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
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/fontanelle'),
      );

      if (response.statusCode == 200) {
        setState(() {
          fontanelle = json.decode(response.body);
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Fontanelle',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: fetchFontanelle),
      ],
      child: ListView.builder(
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
