import "package:go_router/go_router.dart";
import "package:sero/app_shell.dart";
import "package:sero/screens/home.dart";

final router = GoRouter(
  routes: [
    ShellRoute(
      routes: [GoRoute(path: "/", builder: (_, _) => const HomeScreen())],
      builder: (context, state, child) {
        return AppShell(child: child);
      },
    ),
  ],
);
