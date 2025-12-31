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

class ChangeNameScreen extends StatefulWidget {
  final String? currentName;

  const ChangeNameScreen({super.key, required this.currentName});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  String _name = "";
  String? _error;

  Future<void> _updateName() async {
    final repo = AuthRepo(GraphQLProvider.of(context).value);
    final router = GoRouter.of(context);
    final authBloc = context.read<AuthBloc>();
    final response = await repo.updateDisplayName(_name);

    if (response is ApiResponseError<void>) {
      setState(() => _error = response.message);
      return;
    }

    router.pop();
    authBloc.add(AuthUpdateDisplayNameEvent(newName: _name));
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
              onChanged: (value) => setState(() => _name = value),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                hintText: "Your name.",
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
                      onPressed: _updateName,
                      color: Theme.of(context).primaryColor,
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : MaterialButton(
                      onPressed: _updateName,
                      color: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        "Save",
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
