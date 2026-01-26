import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/models/api_response.dart";
import "package:sero/repos/auth.dart";
import "package:sero/widgets/logo.dart";

class ChangeStatusScreen extends StatefulWidget {
  final String? currentStatus;

  const ChangeStatusScreen({super.key, required this.currentStatus});

  @override
  State<ChangeStatusScreen> createState() => _ChangeStatusScreenState();
}

class _ChangeStatusScreenState extends State<ChangeStatusScreen> {
  String _status = "";
  String? _error;

  Future<void> _updateStatus() async {
    final repo = AuthRepo(GraphQLProvider.of(context).value);
    final router = GoRouter.of(context);
    final authBloc = context.read<AuthBloc>();
    final response = await repo.updateStatus(_status);

    if (response is ApiResponseError<void>) {
      setState(() => _error = response.message);
      return;
    }

    router.pop();
    authBloc.add(AuthUpdateStatusEvent(newStatus: _status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Logo(height: 50, width: 50, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _status = value),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                hintText: "What are you upto today?",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error ?? "",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: _updateStatus,
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : MaterialButton(
                      onPressed: _updateStatus,
                      color: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
