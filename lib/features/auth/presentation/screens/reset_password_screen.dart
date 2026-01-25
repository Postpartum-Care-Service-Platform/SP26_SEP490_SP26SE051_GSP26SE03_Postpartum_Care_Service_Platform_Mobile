import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/di/injection_container.dart';
import '../widgets/reset_password_form_widget.dart';
import '../widgets/reset_password_footer_widget.dart';
import '../widgets/login_logo_widget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';

/// Reset Password Screen - UI based on Figma
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppLoading.show(context, message: AppStrings.processing);
          } else {
            AppLoading.hide(context);
          }

          if (state is AuthForgotPasswordSuccess) {
            AppToast.showSuccess(
              context,
              message: state.message,
            );
            AppRouter.pushReplacement(
              context,
              AppRoutes.resetOtpVerification,
              arguments: {'email': state.email},
            );
          } else if (state is AuthError) {
            AppToast.showError(
              context,
              message: state.message,
            );
          }
        },
        child: AuthScaffold(
          footer: ResetPasswordFooterWidget(
            onSignIn: () {
              AppRouter.push(context, AppRoutes.login);
            },
            onSignUp: () {
              AppRouter.push(context, AppRoutes.signUp);
            },
          ),
          children: [
            const LoginLogoWidget(),
            const SizedBox(height: 48),
            Text(
              AppStrings.resetYourPassword,
              textAlign: TextAlign.center,
              style: AppTextStyles.tinos(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.resetPasswordDescription,
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ).copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),
            const ResetPasswordFormWidget(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

