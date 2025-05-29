class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  String? token;
  Map<String, dynamic>? userData;

  bool get isLogged => token != null;

  String? get userId => userData?['_id'];
  String? get email => userData?['email'];

  void saveSession({required String token, required Map<String, dynamic> userData}) {
    this.token = token;
    this.userData = userData;
  }

  void clearSession() {
    token = null;
    userData = null;
  }
}
