class User {
  final String userId;
  final String phone;
  final String? displayName;
  final String createdAt;
  final String? statusText;
  final String? pictureUrl;

  const User({
    required this.userId,
    required this.phone,
    required this.displayName,
    required this.createdAt,
    required this.statusText,
    required this.pictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json["userId"] as String,
      phone: json["phone"] as String,
      displayName: json["displayName"] as String?,
      createdAt: json["createdAt"] as String,
      statusText: json["statusText"] as String?,
      pictureUrl: json["pictureUrl"] as String?,
    );
  }
}
