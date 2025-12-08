import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:intl_phone_field/intl_phone_field.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _phoneNumber = "";

  Future<void> _beginAuth() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const SvgPicture(
                  AssetBytesLoader("assets/vectors/icon.svg.vec"),
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Welcome to Sero", style: TextStyle(fontSize: 25)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IntlPhoneField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Phone",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      helperText: " ",
                      helperStyle: TextStyle(height: 3),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    initialCountryCode: Localizations.localeOf(
                      context,
                    ).countryCode,
                    initialValue: _phoneNumber,
                    onChanged: (value) =>
                        setState(() => _phoneNumber = value.completeNumber),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Platform.isIOS
                      ? CupertinoButton.filled(
                          onPressed: _beginAuth,
                          color: Theme.of(context).primaryColor,
                          child: const Text(
                            "Send",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : MaterialButton(
                          onPressed: _beginAuth,
                          padding: const EdgeInsetsGeometry.all(12),
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            "Send",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
