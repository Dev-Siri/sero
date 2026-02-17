import "package:flutter/material.dart";
import "package:sero/widgets/logo.dart";
import "package:sero/widgets/user_icon.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const UserIcon(),
        centerTitle: true,
        title: const Hero(
          tag: "logo",
          child: Logo(height: 50, width: 50, color: Colors.black),
        ),
      ),
      body: const SafeArea(child: Text("Hello, World!")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => {},
        child: const Icon(Icons.plus_one),
      ),
    );
  }
}
