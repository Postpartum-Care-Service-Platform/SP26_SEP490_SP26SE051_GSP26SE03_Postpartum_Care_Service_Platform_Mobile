import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_logo_widget.dart';
import '../widgets/resend_otp_widget.dart';
import 'new_password_screen.dart';

/// OTP Verification Screen for forgot password - Verify reset OTP with 6 digits
class ResetOtpVerificationScreen extends StatefulWidget {
  final String email;

  const ResetOtpVerificationScreen({super.key, required this.email});

  @override
  State<ResetOtpVerificationScreen> createState() =>
      _ResetOtpVerificationScreenState();
}

class _ResetOtpVerificationScreenState
    extends State<ResetOtpVerificationScreen> {
  late final AuthBloc _authBloc;
  String _otp = '';
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _authBloc = InjectionContainer.authBloc;
  }

  @override
  void dispose() {
    _authBloc.close();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _resendOtp() {
    _authBloc.add(AuthResendOtp(email: widget.email));
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {
      _otp = _controllers.map((c) => c.text).join();
    });
  }

  void _verifyOtp() {
    if (_otp.length != 6) return;
    _authBloc.add(
      AuthVerifyResetOtp(
        email: widget.email,
        otp: _otp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) => _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppLoading.show(context, message: AppStrings.processing);
          } else {
            AppLoading.hide(context);
          }

          if (state is AuthVerifyResetOtpSuccess) {
            AppToast.showSuccess(
              context,
              message: state.message,
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => NewPasswordScreen(
                  resetToken: state.resetToken,
                  email: state.email,
                ),
              ),
            );
          } else if (state is AuthForgotPasswordSuccess) {
            // Resend OTP success
            AppToast.showSuccess(context, message: state.message);
          } else if (state is AuthError) {
            AppToast.showError(
              context,
              message: state.message,
            );
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AuthScaffold(
            children: [
              const LoginLogoWidget(),
              SizedBox(height: 48 * scale),
              Text(
                AppStrings.otpVerificationTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.tinos(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                '${AppStrings.otpVerificationDescription}\n${widget.email}',
                textAlign: TextAlign.center,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.normal,
                ).copyWith(height: 1.5),
              ),
              SizedBox(height: 32 * scale),
              AppWidgets.otpInputRow(
                length: 6,
                controllers: _controllers,
                focusNodes: _focusNodes,
                onChanged: _onOtpChanged,
                boxWidth: 48 * scale,
                boxHeight: 56 * scale,
                spacing: 4 * scale,
              ),
              SizedBox(height: 24 * scale),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AppWidgets.primaryButton(
                    text: AppStrings.otpVerificationButton,
                    onPressed: state is AuthLoading || _otp.length != 6
                        ? () {}
                        : _verifyOtp,
                    isEnabled: state is! AuthLoading && _otp.length == 6,
                  );
                },
              ),
              SizedBox(height: 16 * scale),
              ResendOtpWidget(
                onResendOtp: _resendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


