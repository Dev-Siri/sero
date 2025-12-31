import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:hive_flutter/adapters.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/models/adapters/user_adapter.dart";
import "package:sero/router.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: "Sero",
        routerConfig: router,
        themeMode: ThemeMode.light,
        theme: ThemeData(
          primaryColor: const Color.fromRGBO(0, 85, 255, 1),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          fontFamily: "Geist",
          fontFamilyFallback: const ["AppleColorEmoji", "NotoColorEmoji"],
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Colors.blue.withAlpha(102),
            selectionHandleColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
