class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  String? token;
  Map<String, dynamic>? userData;
  bool? _isAdmin; // campo privato per isAdmin

  bool get isLogged => token != null;

  String? get userId => userData?['id'];
  String? get email => userData?['email'];
  bool? get isAdmin => _isAdmin;

  void saveSession({
    required String token,
    required Map<String, dynamic> userData,
    required bool isAdmin,
  }) {
    this.token = token;
    this.userData = userData;
    _isAdmin = isAdmin;
  }

  void clearSession() {
    token = null;
    userData = null;
    _isAdmin = null;
  }
}
