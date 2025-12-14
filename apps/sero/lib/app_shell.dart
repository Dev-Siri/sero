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
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (widget, animation) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(position: slideAnimation, child: widget);
          },
          child: state is AuthStateAuthorized
              ? KeyedSubtree(key: const ValueKey("authorized"), child: child)
              : const KeyedSubtree(
                  key: ValueKey("login"),
                  child: LoginScreen(),
                ),
        );
      },
    );
  }
}
