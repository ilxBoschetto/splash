import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final userJson = prefs.getString('user_data');

    if (token == null || userJson == null) {
      await logout();
      isUserLogged = false;
    } else {
      final user = json.decode(userJson);
      UserSession().saveSession(
        token: token,
        userData: user,
        isAdmin: user['isAdmin'],
      );
      isUserLogged = true;
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
        await prefs.setString('user_data', json.encode(user));
        final isAdmin = (user['isAdmin'] == true);
        UserSession().saveSession(
          token: token,
          userData: user,
          isAdmin: isAdmin,
        );

        isUserLogged = true;
        return LoginResult(success: true);
      } else {
        return LoginResult(
          success: false,
          errorCode: data['code'],
          message: data['error'],
        );
      }
    } catch (e) {
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
    await prefs.clear();
    isUserLogged = false;
  }

  static Future<LoginResult> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          kIsWeb
              ? dotenv.env['GOOGLE_WEB_CLIENT_ID'] // usato da Edge/Chrome
              : dotenv.env['GOOGLE_ANDROID_CLIENT_ID'],
      scopes: ['email', 'profile'],
    );

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        return LoginResult(success: false, message: 'Accesso annullato.');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      final res = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': idToken}),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_data', json.encode(user));

        UserSession().saveSession(
          token: token,
          userData: user,
          isAdmin: user['isAdmin'] == true,
        );

        isUserLogged = true;
        return LoginResult(success: true);
      } else {
        print('Google login error: ${data['error']}');
        return LoginResult(
          success: false,
          message: data['error'] ?? 'Errore durante il login Google.',
        );
      }
    } catch (e) {
      print('Google login exception: $e');
      return LoginResult(
        success: false,
        message: 'Errore di rete o autenticazione: $e',
      );
    }
  }
}
