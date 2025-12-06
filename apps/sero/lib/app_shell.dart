import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/screens/login.dart";

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateAuthorized) {
          return child;
        }

        return LoginScreen();
      },
    );
  }
}
