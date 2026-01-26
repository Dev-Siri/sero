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
  late final ValueNotifier<GraphQLClient> gqlClient;

  @override
  void initState() {
    super.initState();

    gqlClient = ValueNotifier(createGqlClient(null));

    context.read<AuthBloc>().add(
      AuthAutoLoginUserEvent(gqlClient: gqlClient.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        gqlClient.value = createGqlClient(
          state is AuthStateAuthorized ? state.authToken : null,
        );

        if (state is! AuthStateAuthorized) {
          context.go("/login");
        }
      },
      builder: (context, state) {
        return GraphQLProvider(client: gqlClient, child: widget.child);
      },
    );
  }
}
