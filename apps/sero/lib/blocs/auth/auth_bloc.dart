import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:hive/hive.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/user.dart";
import "package:sero/repos/auth.dart";
import "package:sero/security/encryption.dart";

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
    on<AuthUpdateStatusEvent>(_updateStatus);
    on<AuthUpdatePictureUrlEvent>(_updatePictureUrl);
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

    final cachedState = AuthStateAuthorized(
      user: storedUser,
      authToken: storedAuthToken,
    );
    emit(cachedState);

    final connectivity = Connectivity();
    final connectivityStatus = await connectivity.checkConnectivity();

    if (connectivityStatus.contains(ConnectivityResult.none)) {
      return;
    }

    final repo = AuthRepo(event.gqlClient);
    final user = await repo.fetchUser(storedUser.userId);

    if (user is ApiResponseSuccess<User>) {
      await authBox.put(userKey, user.data);
      emit(
        AuthStateAuthorized(user: user.data, authToken: cachedState.authToken),
      );
    }
  }

  Future<void> _login(AuthLoginUserEvent event, Emitter<AuthState> emit) async {
    final repo = AuthRepo(event.gqlClient);
    final user = await repo.fetchUser(event.userId);

    final keys = await Encrypter.generateKeys();

    await Encrypter.storeKeys(keys);

    final keyResponse = await repo.uploadPublicKey(
      algorithm: keys.algorithm,
      publicKey: keys.publicKey,
      userToken: event.token,
    );

    if (keyResponse is ApiResponseError<void>) {
      return emit(AuthStateError(message: keyResponse.message));
    }

    if (user is ApiResponseSuccess<User>) {
      final authBox = await Hive.openBox(userBoxKey);

      await authBox.put(userKey, user.data);
      await securedStorage.write(key: authTokenKey, value: event.token);

      emit(AuthStateAuthorized(user: user.data, authToken: event.token));
    }
  }

  Future<void> _logout(
    AuthLogoutUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    final repo = AuthRepo(event.gqlClient);
    final response = await repo.revokePublicKey();

    if (response is ApiResponseError<void>) {
      return;
    }

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
    final newUser = authedUser.user.copyWith(displayName: event.newName);

    emit(AuthStateAuthorized(user: newUser, authToken: authedUser.authToken));
    await _saveUser(newUser);
  }

  Future<void> _updateStatus(
    AuthUpdateStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthStateAuthorized) return;

    final authedUser = state as AuthStateAuthorized;
    final newUser = authedUser.user.copyWith(statusText: event.newStatus);

    emit(AuthStateAuthorized(user: newUser, authToken: authedUser.authToken));
    await _saveUser(newUser);
  }

  Future<void> _updatePictureUrl(
    AuthUpdatePictureUrlEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthStateAuthorized) return;

    final authedUser = state as AuthStateAuthorized;
    final newUser = authedUser.user.copyWith(pictureUrl: event.newPictureUrl);

    emit(AuthStateAuthorized(user: newUser, authToken: authedUser.authToken));
    await _saveUser(newUser);
  }

  Future<void> _saveUser(User user) async {
    final authBox = await Hive.openBox(userBoxKey);
    await authBox.put(userKey, user);
  }
}
