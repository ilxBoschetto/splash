import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginResult {
  final bool success;
  final String? errorCode;
  final String? message;

  LoginResult({required this.success, this.errorCode, this.message});
}

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

  static Future<LoginResult> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        UserSession().saveSession(token: token, userData: user);

        isUserLogged = true;
        return LoginResult(success: true);
      } else {
        // Errori con messaggio + codice dal backend
        return LoginResult(
          success: false,
          errorCode: data['code'],
          message: data['error'],
        );
      }
    } catch (e) {
      // Errore di rete o altro imprevisto
      return LoginResult(
        success: false,
        errorCode: 'NETWORK_ERROR',
        message: 'Errore di rete. Riprova.',
      );
    }
  }

  static Future<void> logout() async {
    UserSession().clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    isUserLogged = false;
  }
}
