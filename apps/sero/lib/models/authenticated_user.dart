enum AuthType { newUser, existingUser }

class AuthenticatedUser {
  final String token;
  final String userId;
  final AuthType authType;

  AuthenticatedUser({
    required this.token,
    required this.userId,
    required this.authType,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      token: json["token"] as String,
      userId: json["userId"] as String,
      authType: json["authType"] == "EXISTING"
          ? AuthType.existingUser
          : AuthType.newUser,
    );
  }
}
