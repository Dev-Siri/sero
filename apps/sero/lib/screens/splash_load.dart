import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/widgets/logo.dart";

class SplashLoadScreen extends StatelessWidget {
  const SplashLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        final router = GoRouter.of(context);

        if (state is AuthStateAuthorized) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => router.go("/home"),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: const SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "logo",
                  child: Logo(height: 200, width: 200, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
