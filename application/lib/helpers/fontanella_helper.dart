import 'dart:convert';

import 'package:application/helpers/user_session.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// used for mediaType
import 'package:http_parser/http_parser.dart';

class FontanellaHelper
{
  final baseUrl = dotenv.env['API_URL'];

  Future<http.Response> fetchFountains() async {
    final userSession = UserSession();
    final response = await http.get(
      Uri.parse('$baseUrl/fontanelle'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> createFountain(Map<String, dynamic> fountainData) async {
    final userSession = UserSession();
    final response = await http.post(
      Uri.parse('$baseUrl/fontanelle'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(fountainData),
    );
    return response;
  }

  Future<http.Response> deleteFountain(String id) async {
    final userSession = UserSession();
    final response = await http.delete(
      Uri.parse('$baseUrl/fontanelle/$id'),
      headers: {
        'Authorization': 'Bearer ${userSession.token}',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> fetchFontanelleCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fontanelle/count')
    );
    return response;
  }

  Future<http.Response> getFontanelleToday() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fontanelle/today')
    );
    return response;
  }

  Future<http.Response> getTopUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/top')
    );
    return response;
  }

  Future<http.Response> getUserSavedFontanellaCount() async {
    final userId = UserSession().userId;
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/saved_fontanella_count')
    );
    return response;
  }

  Future<http.Response> getUserCreatedFontanellaCount() async {
    final userId = UserSession().userId;
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/created_fontanella_count')
    );
    return response;
  }

  Future<http.Response> uploadFountainImage(String fontanellaId, XFile? image) async {
    final userSession = UserSession();
    final uri = Uri.parse(
      '$baseUrl/fontanelle/$fontanellaId/image',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${userSession.token}';
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}