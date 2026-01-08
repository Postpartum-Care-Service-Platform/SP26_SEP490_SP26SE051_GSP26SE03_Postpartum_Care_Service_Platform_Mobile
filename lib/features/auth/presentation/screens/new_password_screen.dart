import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_logo_widget.dart';
import 'login_screen.dart';

/// New Password Screen - for resetting password after verifying OTP
class NewPasswordScreen extends StatefulWidget {
  final String resetToken;
  final String email;

  const NewPasswordScreen({
    super.key,
    required this.resetToken,
    required this.email,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  late final AuthBloc _authBloc;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _authBloc = InjectionContainer.authBloc;
  }

  @override
  void dispose() {
    _authBloc.close();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() == true) {
      _authBloc.add(
        AuthResetPassword(
          resetToken: widget.resetToken,
          newPassword: _passwordController.text,
          confirmNewPassword: _confirmPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppLoading.show(context, message: AppStrings.processing);
          } else {
            AppLoading.hide(context);
          }

          if (state is AuthResetPasswordSuccess) {
            AppToast.showSuccess(
              context,
              message: state.message,
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } else if (state is AuthError) {
            AppToast.showError(
              context,
              message: state.message,
            );
          }
        },
        child: AuthScaffold(
          children: [
            const LoginLogoWidget(),
            const SizedBox(height: 48),
            Text(
              AppStrings.resetPassword,
              textAlign: TextAlign.center,
              style: AppTextStyles.tinos(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppWidgets.textInput(
                    label: AppStrings.password,
                    placeholder: AppStrings.passwordPlaceholder,
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorInputPasswordRequired;
                      }
                      if (value.length < 6) {
                        return AppStrings.errorInputPasswordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppWidgets.textInput(
                    label: AppStrings.confirmPassword,
                    placeholder: AppStrings.confirmPasswordPlaceholder,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onTogglePassword: () {
                      setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorInputConfirmPassword;
                      }
                      if (value != _passwordController.text) {
                        return AppStrings.errorInputPasswordsNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppWidgets.primaryButton(
                        text: AppStrings.resetPassword,
                        onPressed:
                            state is AuthLoading ? () {} : _onSubmit,
                        isEnabled: state is! AuthLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


