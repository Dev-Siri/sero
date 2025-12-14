import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/authenticated_user.dart";

class CompleteAuth extends StatefulWidget {
  final String sessionId;
  final String phone;

  const CompleteAuth({super.key, required this.sessionId, required this.phone});

  @override
  State<CompleteAuth> createState() => _CompleteAuthState();
}

class _CompleteAuthState extends State<CompleteAuth> {
  @override
  void initState() {
    _completeAuth();
    super.initState();
  }

  Future<void> _completeAuth() async {
    final authBloc = context.read<AuthBloc>();
    final user = await context.read<AuthBloc>().repo.completeAuth(
      sessionId: widget.sessionId,
      phone: widget.phone,
    );

    if (user is ApiResponseSuccess<AuthenticatedUser>) {
      authBloc.add(
        AuthLoginUserEvent(token: user.data.token, userId: user.data.userId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }
}
