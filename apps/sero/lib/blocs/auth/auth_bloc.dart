import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:hive/hive.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/user.dart";
import "package:sero/repos/auth.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const userBoxKey = "auth";
  static const userKey = "user";
  static const authTokenKey = "user_auth_token";

  final FlutterSecureStorage securedStorage;

  AuthBloc(this.securedStorage) : super(AuthStateInitial()) {
    on<AuthLoginUserEvent>(_login);
    on<AuthAutoLoginUserEvent>(_autoLogin);
    on<AuthLogoutUserEvent>(_logout);
    on<AuthUpdateDisplayNameEvent>(_updateDisplayName);
  }

  Future<void> _autoLogin(
    AuthAutoLoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    final authBox = await Hive.openBox(userBoxKey);
    final storedUser = (await authBox.get(userKey)) as User?;
    final storedAuthToken = await securedStorage.read(key: authTokenKey);

    if (storedUser == null || storedAuthToken == null) {
      return emit(AuthStateUnauthorized());
    }

    emit(AuthStateAuthorized(user: storedUser, authToken: storedAuthToken));
  }

  Future<void> _login(AuthLoginUserEvent event, Emitter<AuthState> emit) async {
    final repo = AuthRepo(event.gqlClient);
    final user = await repo.fetchUser(event.userId);

    if (user is ApiResponseSuccess<User>) {
      final authBox = await Hive.openBox(userBoxKey);

      await authBox.put(userKey, user.data);
      await securedStorage.write(key: authTokenKey, value: event.token);

      return emit(AuthStateAuthorized(user: user.data, authToken: event.token));
    }
  }

  Future<void> _logout(
    AuthLogoutUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    final authBox = await Hive.openBox(userBoxKey);

    await authBox.delete(userKey);
    await securedStorage.delete(key: authTokenKey);

    return emit(AuthStateUnauthorized());
  }

  Future<void> _updateDisplayName(
    AuthUpdateDisplayNameEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthStateAuthorized) return;

    final authedUser = state as AuthStateAuthorized;
    final newUser = User(
      userId: authedUser.user.userId,
      phone: authedUser.user.phone,
      displayName: event.newName,
      createdAt: authedUser.user.createdAt,
      statusText: authedUser.user.statusText,
      pictureUrl: authedUser.user.pictureUrl,
    );

    emit(AuthStateAuthorized(user: newUser, authToken: authedUser.authToken));

    final authBox = await Hive.openBox(userBoxKey);

    await authBox.put(userKey, newUser);
  }
}
