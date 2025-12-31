import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:sero/widgets/logo.dart";

class SplashLoadScreen extends StatefulWidget {
  const SplashLoadScreen({super.key});

  @override
  State<SplashLoadScreen> createState() => _SplashLoadScreenState();
}

class _SplashLoadScreenState extends State<SplashLoadScreen> {
  @override
  void initState() {
    final router = GoRouter.of(context);
    Future.delayed(const Duration(seconds: 1), () => router.go("/home"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "logo",
              child: Logo(height: 200, width: 200, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
