import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

/// Login Form Widget - Contains email, password fields and sign in button
class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
            LoginWithEmailPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isObscured = state.isPasswordObscured;

        return Form(
          key: _formKey,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Email field
              AppWidgets.textInput(
                label: AppStrings.email,
                placeholder: AppStrings.emailPlaceholder,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 23.992),
              // Password field
              AppWidgets.textInput(
                label: AppStrings.password,
                placeholder: AppStrings.passwordPlaceholder,
                controller: _passwordController,
                isPassword: true,
                obscureText: isObscured,
                onTogglePassword: () {
                  context.read<LoginBloc>().add(const TogglePasswordVisibility());
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 23.992),
              // Sign in button
              AppWidgets.primaryButton(
                text: AppStrings.signIn,
                onPressed: state is LoginLoading ? () {} : _handleSignIn,
                isEnabled: state is! LoginLoading,
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}

