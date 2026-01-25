import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_logo_widget.dart';
import '../widgets/sign_up_form_widget.dart';
import '../widgets/sign_up_footer_widget.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';

/// Sign Up Screen - built based on existing auth screens
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = AppResponsive.isTablet(context);

    return BlocProvider(
      create: (context) => InjectionContainer.authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppLoading.show(context, message: AppStrings.processing);
          } else if (state is AuthRegisterSuccess) {
            AppLoading.hide(context);
            AppToast.showSuccess(
              context,
              message: state.message,
            );
            AppRouter.pushReplacement(
              context,
              AppRoutes.otpVerification,
              arguments: {'email': state.email},
            );
          } else if (state is AuthError) {
            AppLoading.hide(context);
            AppToast.showError(
              context,
              message: state.message,
            );
          }
        },
        child: AuthScaffold(
      footer: SignUpFooterWidget(
        onSignIn: () => AppRouter.pop(context),
      ),
      children: [
        const LoginLogoWidget(),
        const SizedBox(height: 48),
        Text(
          AppStrings.signUpTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.tinos(
            fontSize: isWide ? 20 : 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.signUpDescription,
          textAlign: TextAlign.center,
          style: AppTextStyles.arimo(
            fontSize: isWide ? 16 : 14,
            fontWeight: FontWeight.normal,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 32),
        const SignUpFormWidget(),
      ],
        ),
      ),
    );
  }
}

