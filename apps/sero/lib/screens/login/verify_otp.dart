import "package:flutter/material.dart";
import "package:flutter_otp_text_field/flutter_otp_text_field.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";

class VerifyOtp extends StatelessWidget {
  final String sessionId;
  final String phone;
  final String? error;

  final void Function(String value) onSubmit;
  final void Function() onBack;

  const VerifyOtp({
    super.key,
    required this.sessionId,
    required this.phone,
    required this.onSubmit,
    required this.onBack,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: BackButton(onPressed: onBack),
          centerTitle: true,
          title: const SvgPicture(
            AssetBytesLoader("assets/vectors/icon.svg.vec"),
            height: 40,
            width: 40,
            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 150),
        const Text("Enter One-Time Password", style: TextStyle(fontSize: 25)),
        Padding(
          padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
          child: Text(
            "We sent an one-time password (OTP) to $phone. Check your message inbox.",
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: OtpTextField(
            numberOfFields: 6,
            onSubmit: (otp) => onSubmit(otp),
            autoFocus: true,
          ),
        ),
        const SizedBox(height: 10),
        if (error != null)
          Text(
            error ?? "",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
