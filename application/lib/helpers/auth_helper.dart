import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
}
