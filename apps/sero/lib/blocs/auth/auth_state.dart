import "package:flutter/foundation.dart";
import "package:sero/models/user.dart";

@immutable
sealed class AuthState {}

class AuthStateInitial extends AuthState {}

class AuthStateError extends AuthState {
  final String message;

  AuthStateError({required this.message});
}

class AuthStateUnauthorized extends AuthState {}

class AuthStateAuthorized extends AuthState {
  final User user;
  final String authToken;

  AuthStateAuthorized({required this.user, required this.authToken});
}
