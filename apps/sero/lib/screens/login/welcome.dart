import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:intl_phone_field/country_picker_dialog.dart";
import "package:intl_phone_field/intl_phone_field.dart";
import "package:sero/widgets/logo.dart";

class LoginWelcome extends StatefulWidget {
  final void Function(String value) onSubmit;
  final String? errorText;

  const LoginWelcome({
    super.key,
    required this.onSubmit,
    required this.errorText,
  });

  @override
  State<LoginWelcome> createState() => _LoginWelcomeState();
}

class _LoginWelcomeState extends State<LoginWelcome> {
  String _phoneNumber = "";
  String? _shownError;

  bool _isLoading = false;

  @override
  void initState() {
    setState(() => _shownError = widget.errorText);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() => _shownError = widget.errorText);
    super.didChangeDependencies();
  }

  void _handleSubmit() {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    widget.onSubmit(_phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 150),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 90),
              child: Transform.rotate(
                angle: 85,
                child: Container(
                  height: 50,
                  width: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Logo(height: 150, width: 150, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Welcome to Sero", style: TextStyle(fontSize: 25)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IntlPhoneField(
              keyboardType: TextInputType.phone,
              pickerDialogStyle: PickerDialogStyle(
                backgroundColor: Colors.white,
                searchFieldCursorColor: Colors.black,
                width: MediaQuery.sizeOf(context).width - 20,
                countryNameStyle: const TextStyle(fontSize: 16),
                searchFieldInputDecoration: const InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIconColor: Colors.black,
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search for a country...",
                ),
              ),
              decoration: InputDecoration(
                hintText: "Phone",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                helperText: " ",
                errorText: _shownError,
                helperStyle: const TextStyle(height: 3),
              ),
              cursorColor: Theme.of(context).primaryColor,
              initialCountryCode: Localizations.localeOf(context).countryCode,
              initialValue: _phoneNumber,
              onChanged: (value) => setState(() {
                _phoneNumber = value.completeNumber;
                _shownError = null;
              }),
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
                    onPressed: _handleSubmit,
                    color: Theme.of(context).primaryColor,
                    disabledColor: Colors.grey,
                    child: const Text(
                      "Send",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : MaterialButton(
                    onPressed: _handleSubmit,
                    padding: const EdgeInsetsGeometry.all(12),
                    color: Theme.of(context).primaryColor,
                    disabledColor: Colors.grey,
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
    );
  }
}
