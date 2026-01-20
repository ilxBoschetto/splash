import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> sendTokenToBackend(String? token) async {
  if (token == null) return;

  final prefs = await SharedPreferences.getInstance();
  final jwtToken = prefs.getString('jwt_token');

  try {
    final res = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/users/device-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode({'deviceToken': token}),
    );

    if (res.statusCode != 200) {
      debugPrint('Failed to send device token to backend: ${res.body}');
    }
  } catch (e) {
    debugPrint('Error sending device token to backend: $e');
  }
}