import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const userKey = "user";
  static const authTokenKey = "user_auth_token";

  final FlutterSecureStorage securedStorage;

  AuthBloc(this.securedStorage) : super(AuthStateInitial());
}
