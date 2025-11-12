import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'user_session.dart';

class LoginResult {
  final bool success;
  final String? errorCode;
  final String? message;

  LoginResult({required this.success, this.errorCode, this.message});
}

class AuthHelper {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID_RELEASE']!,
  );
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
        isAdmin: user['isAdmin'] == true,
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

        UserSession().saveSession(
          token: token,
          userData: user,
          isAdmin: user['isAdmin'] == true,
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
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.disconnect();
    }
    UserSession().clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    isUserLogged = false;
  }

  static Future<LoginResult> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return LoginResult(
          success: false,
          message: 'Login Google annullato dall\'utente.',
        );
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        return LoginResult(success: false, message: 'Token Google non valido.');
      }

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
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.disconnect();
        }
        debugPrint('Google login error: ${data['error']}');
        return LoginResult(
          success: false,
          message: data['error'] ?? 'Errore durante il login Google.',
        );
      }
    } catch (e) {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      debugPrint('Google login exception: $e');
      return LoginResult(
        success: false,
        message: 'Errore di rete o autenticazione: $e',
      );
    }
  }
}
