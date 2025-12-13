import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/repos/auth.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const userKey = "user";
  static const authTokenKey = "user_auth_token";

  final FlutterSecureStorage securedStorage;
  final GraphQLClient gql;

  AuthBloc(this.securedStorage, this.gql) : super(AuthStateInitial()) {
    // on<AuthCreateSessionEvent>(_createSession);
  }

  AuthRepo get repo => AuthRepo(gql);

  // Future<void> _createSession(
  //   AuthCreateSessionEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   final r = await repo.createSession(phone: "+919674822408");

  //   print(r);
  // }
}
