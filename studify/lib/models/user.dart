class User {
  final int? id;
  final String username;
  final String password;
  final UserType type;
  final String? parentEmail; // Pour les étudiants liés à un parent

  User({
    this.id,
    required this.username,
    required this.password,
    required this.type,
    this.parentEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'type': type.toString().split('.').last,
      'parentEmail': parentEmail,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      type: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => UserType.student,
      ),
      parentEmail: map['parentEmail'] as String?,
    );
  }
}

enum UserType {
  admin,
  parent,
  student,
}
