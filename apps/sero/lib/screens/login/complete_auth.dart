import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/authenticated_user.dart";
import "package:sero/repos/auth.dart";
import "package:sero/widgets/logo.dart";

class CompleteAuth extends StatefulWidget {
  final String sessionId;
  final String phone;
  final void Function(String error) onError;

  const CompleteAuth({
    super.key,
    required this.sessionId,
    required this.phone,
    required this.onError,
  });

  @override
  State<CompleteAuth> createState() => _CompleteAuthState();
}

class _CompleteAuthState extends State<CompleteAuth> {
  AuthRepo? _repo;

  Future<void> _completeAuth() async {
    if (_repo == null) return;

    final authBloc = context.read<AuthBloc>();
    final user = await _repo!.completeAuth(
      sessionId: widget.sessionId,
      phone: widget.phone,
    );

    if (user is ApiResponseSuccess<AuthenticatedUser>) {
      authBloc.add(
        AuthLoginUserEvent(
          gqlClient: _repo!.gqlClient,
          token: user.data.token,
          userId: user.data.userId,
        ),
      );
    } else if (user is ApiResponseError<AuthenticatedUser>) {
      widget.onError(user.message);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_repo == null) {
      final client = GraphQLProvider.of(context).value;
      _repo = AuthRepo(client);
      _completeAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateAuthorized) {
          context.go("/home");
        }
        if (state is AuthStateError) {
          widget.onError(state.message);
        }
      },
      builder: (context, state) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Hero(tag: "logo", child: Logo(height: 200, width: 200))],
        );
      },
    );
  }
}
