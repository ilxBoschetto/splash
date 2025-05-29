import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthHelper {
  static bool isUserLogged = false;

  static Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      isUserLogged = true;
    } else {
      isUserLogged = false;
    }
  }

  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final token = data['token'];
      final user = data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      UserSession().saveSession(token: token, userData: user);

      isUserLogged = true;
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    UserSession().clearSession();
  }
}
