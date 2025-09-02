class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, this.email = ''});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'].toString(),
      name: json['name'] ?? '-',
      email: json['email'] ?? '-',
    );
  }
}
