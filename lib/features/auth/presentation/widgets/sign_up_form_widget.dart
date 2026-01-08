import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Sign Up Form Widget - built based on existing auth widgets
class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed(BuildContext context) {
    if (_formKey.currentState?.validate() == true) {
      context.read<AuthBloc>().add(
            AuthRegister(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              phone: _phoneController.text.trim(),
              username: _usernameController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppWidgets.textInput(
                label: AppStrings.username,
                placeholder: AppStrings.usernamePlaceholder,
                controller: _usernameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.errorInputUsername;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppWidgets.textInput(
                label: AppStrings.email,
                placeholder: AppStrings.emailPlaceholder,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.errorInputEmailRequired;
                  }
                  if (!value.contains('@')) {
                    return AppStrings.errorInputEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppWidgets.textInput(
                label: AppStrings.phone,
                placeholder: AppStrings.phonePlaceholder,
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.errorInputPhone;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
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
              const SizedBox(height: 23.992),
              AppWidgets.primaryButton(
                text: AppStrings.signUp,
                onPressed: state is AuthLoading
                    ? () {}
                    : () => _onSignUpPressed(context),
                isEnabled: state is! AuthLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}

