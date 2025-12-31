import "package:go_router/go_router.dart";
import "package:sero/app_shell.dart";
import "package:sero/screens/change_name.dart";
import "package:sero/screens/edit_profile.dart";
import "package:sero/screens/home.dart";
import "package:sero/screens/login.dart";
import "package:sero/screens/profile.dart";
import "package:sero/screens/splash_load.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        GoRoute(path: "/", builder: (_, _) => const SplashLoadScreen()),
        GoRoute(path: "/home", builder: (_, _) => const HomeScreen()),
        GoRoute(path: "/login", builder: (_, _) => const LoginScreen()),
        GoRoute(path: "/profile", builder: (_, _) => const ProfileScreen()),
        GoRoute(
          path: "/profile/edit",
          builder: (_, _) => const EditProfileScreen(),
        ),
        GoRoute(
          path: "/profile/edit/name",
          builder: (_, state) => ChangeNameScreen(
            currentName: state.uri.queryParameters["currentName"],
          ),
        ),
      ],
      builder: (context, state, child) {
        return AppShell(child: child);
      },
    ),
  ],
);
