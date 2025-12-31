import "package:flutter/foundation.dart";
import "package:graphql_flutter/graphql_flutter.dart";

@immutable
sealed class AuthEvent {}

class AuthAutoLoginUserEvent extends AuthEvent {}

class AuthLoginUserEvent extends AuthEvent {
  final GraphQLClient gqlClient;
  final String token;
  final String userId;

  AuthLoginUserEvent({
    required this.gqlClient,
    required this.token,
    required this.userId,
  });
}

class AuthLogoutUserEvent extends AuthEvent {}

class AuthUpdateDisplayNameEvent extends AuthEvent {
  final String newName;

  AuthUpdateDisplayNameEvent({required this.newName});
}
