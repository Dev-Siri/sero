import "package:flutter/foundation.dart";

@immutable
sealed class AuthState {}

class AuthStateInitial extends AuthState {}

class AuthStateUnauthorized extends AuthState {}

class AuthStateAuthorized extends AuthState {
  final UnimplementedError user;
  final String authToken;

  AuthStateAuthorized({required this.user, required this.authToken});
}
