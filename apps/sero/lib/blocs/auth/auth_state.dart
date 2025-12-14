import "package:flutter/foundation.dart";
import "package:sero/models/user.dart";

@immutable
sealed class AuthState {}

class AuthStateInitial extends AuthState {}

class AuthStateUnauthorized extends AuthState {}

class AuthStateAuthorized extends AuthState {
  final User user;
  final String authToken;

  AuthStateAuthorized({required this.user, required this.authToken});
}
