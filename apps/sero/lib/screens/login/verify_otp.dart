import "package:flutter/material.dart";
import "package:flutter_otp_text_field/flutter_otp_text_field.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";

class VerifyOtp extends StatefulWidget {
  final String sessionId;
  final String phone;
  final String? error;

  final void Function(String value) onSubmit;
  final void Function() onBack;
  final Future<void> Function() onResend;

  const VerifyOtp({
    super.key,
    required this.sessionId,
    required this.phone,
    required this.onSubmit,
    required this.onBack,
    required this.onResend,
    required this.error,
  });

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  String _resendBtnText = "Resend";

  Future<void> _handleResend() async {
    setState(() => _resendBtnText = "Resending...");
    await widget.onResend();

    setState(() {
      Future.delayed(
        const Duration(seconds: 3),
        () => _resendBtnText = "Resend",
      );
      _resendBtnText = "Resent";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: BackButton(onPressed: widget.onBack),
          centerTitle: true,
          title: const SvgPicture(
            AssetBytesLoader("assets/vectors/icon.svg.vec"),
            height: 40,
            width: 40,
            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 150),
              const Text(
                "Enter One-Time Password",
                style: TextStyle(fontSize: 25),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
                child: Text(
                  "We sent an one-time password (OTP) to ${widget.phone}. Check your message inbox.",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: OtpTextField(
                  numberOfFields: 6,
                  onSubmit: (otp) => widget.onSubmit(otp),
                  autoFocus: true,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: AlignmentGeometry.centerEnd,
                  child: TextButton(
                    onPressed: _resendBtnText != "Resend"
                        ? null
                        : _handleResend,
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.zero),
                    ),
                    child: Text(
                      _resendBtnText,
                      style: TextStyle(
                        color: _resendBtnText != "Resend"
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.error != null)
                Text(
                  widget.error ?? "",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
