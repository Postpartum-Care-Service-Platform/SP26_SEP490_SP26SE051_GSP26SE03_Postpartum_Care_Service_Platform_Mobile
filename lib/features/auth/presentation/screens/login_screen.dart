import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/login_logo_widget.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/login_form_widget.dart';
import '../widgets/login_footer_widget.dart';
import 'reset_password_screen.dart';
import 'sign_up_screen.dart';
import '../../../../core/utils/app_responsive.dart';

/// Login Screen - Main login page following clean architecture + BloC pattern
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 600;
    final contentWidth = AppResponsive.maxContentWidth(context);

    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // TODO: Navigate to home screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppResponsive.pagePadding(context),
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: AppResponsive.topSpacing(context)),
                      // Logo and app name
                      const LoginLogoWidget(),
                      const SizedBox(height: 48),
                      // Sign in title
                      Text(
                        AppStrings.signInTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.tinos(
                          fontSize: isWide ? 20 : 16,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Google sign in button
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return GoogleSignInButton(
                            onPressed: state is LoginLoading
                                ? () {}
                                : () {
                                    context
                                        .read<LoginBloc>()
                                        .add(const LoginWithGoogle());
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
                      // Footer links
                      LoginFooterWidget(
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
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

