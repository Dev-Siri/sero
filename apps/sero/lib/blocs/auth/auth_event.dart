import "package:flutter/foundation.dart";

@immutable
sealed class AuthEvent {}

class AuthLocalUserFetchEvent extends AuthEvent {}

class AuthLoginUserEvent extends AuthEvent {
  final String token;
  final String userId;

  AuthLoginUserEvent({required this.token, required this.userId});
}

class AuthLogoutUserEvent extends AuthEvent {}
