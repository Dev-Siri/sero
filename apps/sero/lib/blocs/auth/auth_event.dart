import "package:flutter/foundation.dart";

@immutable
sealed class AuthEvent {}

class AuthLocalUserFetchEvent extends AuthEvent {}

class AuthLogoutUserEvent extends AuthEvent {}
