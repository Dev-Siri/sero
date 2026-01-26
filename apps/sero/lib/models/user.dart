import "package:hive_flutter/adapters.dart";

part "user.g.dart";

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String phone;
  @HiveField(2)
  final String? displayName;
  @HiveField(3)
  final String createdAt;
  @HiveField(4)
  final String? statusText;
  @HiveField(5)
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

  User copyWith({
    String? userId,
    String? phone,
    String? displayName,
    String? createdAt,
    String? statusText,
    String? pictureUrl,
  }) {
    return User(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      statusText: statusText ?? this.statusText,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }
}
