import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/user.dart";
import "package:sero/repos/auth.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const userKey = "user";
  static const authTokenKey = "user_auth_token";

  final FlutterSecureStorage securedStorage;
  final GraphQLClient gql;

  AuthBloc(this.securedStorage, this.gql) : super(AuthStateInitial()) {
    on<AuthLoginUserEvent>(_loginUser);
  }

  AuthRepo get repo => AuthRepo(gql);

  Future<void> _loginUser(
    AuthLoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = await repo.fetchUser(event.userId);

    if (user is ApiResponseSuccess<User>) {
      return emit(AuthStateAuthorized(user: user.data, authToken: event.token));
    }
  }
}
