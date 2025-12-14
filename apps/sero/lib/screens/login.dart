import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/otp_validity_status.dart";
import "package:sero/screens/login/complete_auth.dart";
import "package:sero/screens/login/verify_otp.dart";
import "package:sero/screens/login/welcome.dart";

enum LoginStep { welcome, otpVerify, completeAuth }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginStep _currentStep = LoginStep.welcome;
  String? _error;
  String? _phone;

  String? _sessionId;
  bool _isOtpVerified = false;

  Future<void> _beginAuth(String phone) async {
    final createdSession = await context.read<AuthBloc>().repo.createSession(
      phone: phone,
    );

    if (createdSession is ApiResponseError<String>) {
      setState(() => _error = createdSession.message);
      return;
    }

    setState(() {
      _error = null;
      _sessionId = (createdSession as ApiResponseSuccess<String>).data;
      _currentStep = LoginStep.otpVerify;
      _phone = phone;
    });
  }

  Future<void> _verifyOtp(String otp) async {
    if (_sessionId == null) return;

    final otpValidityStatus = await context.read<AuthBloc>().repo.verifyOtp(
      otp: otp,
      sessionId: _sessionId ?? "",
    );

    if (otpValidityStatus is ApiResponseError<OtpValidityStatus>) {
      setState(() => _error = otpValidityStatus.message);
      return;
    }

    final status =
        (otpValidityStatus as ApiResponseSuccess<OtpValidityStatus>).data;

    setState(() {
      switch (status) {
        case OtpValidityStatus.valid:
          _isOtpVerified = true;
          _currentStep = LoginStep.completeAuth;
          break;
        case OtpValidityStatus.invalid:
          _error = "Invalid OTP. Try again.";
        case OtpValidityStatus.expired:
          _error = "The OTP has expired. Try resending OTP.";
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_sessionId == null || _phone == null) return;

    final resendResponse = await context.read<AuthBloc>().repo.resendOtp(
      sessionId: _sessionId ?? "",
      phone: _phone ?? "",
    );

    if (resendResponse is ApiResponseError<void>) {
      setState(() => _error = "Failed to resend OTP.");
    }
  }

  void _revertToFirstStep() => setState(() {
    _currentStep = LoginStep.welcome;
    _sessionId = null;
    _isOtpVerified = false;
    _error = null;
    _phone = null;
  });

  Widget _buildStep() {
    if (_currentStep == LoginStep.welcome && _sessionId == null) {
      return LoginWelcome(
        onSubmit: (phone) => _beginAuth(phone),
        errorText: _error,
      );
    }

    if (_currentStep == LoginStep.otpVerify &&
        !_isOtpVerified &&
        _sessionId != null) {
      return VerifyOtp(
        sessionId: _sessionId ?? "",
        phone: _phone ?? "",
        onSubmit: _verifyOtp,
        onBack: _revertToFirstStep,
        onResend: _resendOtp,
        error: _error,
      );
    }

    if (_currentStep == LoginStep.completeAuth &&
        _sessionId != null &&
        _phone != null) {
      return CompleteAuth(sessionId: _sessionId ?? "", phone: _phone ?? "");
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, -2),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(position: offsetAnimation, child: child);
            },
            child: _buildStep(),
          ),
        ),
      ),
    );
  }
}
