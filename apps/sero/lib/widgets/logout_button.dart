import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_event.dart";

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.read<AuthBloc>().add(
        AuthLogoutUserEvent(gqlClient: GraphQLProvider.of(context).value),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      title: const Text("Logout", style: TextStyle(color: Colors.red)),
    );
  }
}
