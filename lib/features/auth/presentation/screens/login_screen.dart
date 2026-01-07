import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_logo_widget.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/login_form_widget.dart';
import '../widgets/login_footer_widget.dart';
import 'reset_password_screen.dart';
import 'sign_up_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';

/// Login Screen - Main login page following clean architecture + BloC pattern
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AppScaffold()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AuthScaffold(
            footer: LoginFooterWidget(
              onSignUp: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignUpScreen(),
                  ),
                );
              },
              onForgotPassword: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResetPasswordScreen(),
                  ),
                );
              },
            ),
            children: [
              // Logo and app name
              const LoginLogoWidget(),
              const SizedBox(height: 48),
              // Sign in title
              Text(
                AppStrings.signInTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.tinos(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 32),
              // Google sign in button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return GoogleSignInButton(
                    onPressed: state is AuthLoading
                        ? () {}
                        : () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthLoginWithGoogle());
                          },
                  );
                },
              ),
              const SizedBox(height: 24),
              // Divider with "or"
              AppWidgets.orDivider(),
              const SizedBox(height: 24),
              // Login form
              const LoginFormWidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

