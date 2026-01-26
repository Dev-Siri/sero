import "package:flutter/foundation.dart";
import "package:graphql_flutter/graphql_flutter.dart";

@immutable
sealed class AuthEvent {}

class AuthAutoLoginUserEvent extends AuthEvent {
  final GraphQLClient gqlClient;

  AuthAutoLoginUserEvent({required this.gqlClient});
}

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

class AuthLogoutUserEvent extends AuthEvent {
  final GraphQLClient gqlClient;

  AuthLogoutUserEvent({required this.gqlClient});
}

class AuthUpdateDisplayNameEvent extends AuthEvent {
  final String newName;

  AuthUpdateDisplayNameEvent({required this.newName});
}

class AuthUpdateStatusEvent extends AuthEvent {
  final String newStatus;

  AuthUpdateStatusEvent({required this.newStatus});
}

class AuthUpdatePictureUrlEvent extends AuthEvent {
  final String newPictureUrl;

  AuthUpdatePictureUrlEvent({required this.newPictureUrl});
}
