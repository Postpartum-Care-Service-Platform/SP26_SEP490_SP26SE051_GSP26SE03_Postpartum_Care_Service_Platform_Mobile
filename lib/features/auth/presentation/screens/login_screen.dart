import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_loading.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_logo_widget.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/login_form_widget.dart';
import '../widgets/login_footer_widget.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_toast.dart';
import 'reset_password_screen.dart';
import 'sign_up_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../employee/presentation/screens/employee_portal_screen.dart';
import '../../../../core/config/app_config.dart';

// Google Sign-In configuration using Web Client ID from AppConfig
// AppConfig loads the value from .env file
final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: AppConfig.googleWebClientId,
);

/// Login Screen - Main login page following clean architecture + BloC pattern
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppLoading.show(context, message: AppStrings.processing);
          } else if (state is AuthSuccess) {
            AppLoading.hide(context);
            AppToast.showSuccess(context, message: AppStrings.successLogin);
            final role = state.user?.role.toLowerCase();
            final isEmployee =
                role == 'staff' || role == 'manager' || role == 'admin';
            final destination = isEmployee
                ? const EmployeePortalScreen()
                : const AppScaffold();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => destination),
            );
          } else if (state is AuthError) {
            AppLoading.hide(context);
            AppToast.showError(context, message: state.message);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AuthScaffold(
            footer: LoginFooterWidget(
              onSignUp: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
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
                        : () async {
                            try {
                              final GoogleSignInAccount? account =
                                  await _googleSignIn.signIn();
                              if (account != null) {
                                final GoogleSignInAuthentication auth =
                                    await account.authentication;
                                final String? idToken = auth.idToken;
                                if (idToken != null) {
                                  context.read<AuthBloc>().add(
                                    AuthLoginWithGoogle(idToken: idToken),
                                  );
                                } else {
                                  AppToast.showError(
                                    context,
                                    message: 'Không thể lấy idToken từ Google',
                                  );
                                }
                              }
                            } catch (e) {
                              AppToast.showError(
                                context,
                                message:
                                    'Lỗi đăng nhập Google: ${e.toString()}',
                              );
                            }
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
