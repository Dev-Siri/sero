import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/graphql/client.dart";

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    context.read<AuthBloc>().add(AuthAutoLoginUserEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthStateAuthorized) {
          context.go("/login");
        }
      },
      builder: (context, state) {
        final gqlClient = createGqlClient(
          state is AuthStateAuthorized ? state.authToken : null,
        );

        return GraphQLProvider(
          client: ValueNotifier(gqlClient),
          child: widget.child,
        );
      },
    );
  }
}
