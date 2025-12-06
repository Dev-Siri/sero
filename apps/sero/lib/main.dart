import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/router.dart";

void main() {
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
      child: SafeArea(
        child: MaterialApp.router(
          title: "Wavelength",
          routerConfig: router,
          themeMode: ThemeMode.light,
          theme: ThemeData(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
            fontFamily: "Geist",
            fontFamilyFallback: const ["AppleColorEmoji", "NotoColorEmoji"],
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: Colors.blue.withAlpha(102),
              selectionHandleColor: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
