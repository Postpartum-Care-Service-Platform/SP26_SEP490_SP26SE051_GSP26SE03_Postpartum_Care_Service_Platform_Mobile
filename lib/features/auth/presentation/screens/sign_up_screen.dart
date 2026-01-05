import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/login_logo_widget.dart';
import '../widgets/sign_up_form_widget.dart';
import '../widgets/sign_up_footer_widget.dart';

/// Sign Up Screen - built based on existing auth screens (no Figma MCP)
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentWidth = AppResponsive.maxContentWidth(context);
    final isWide = AppResponsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: AppResponsive.pagePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppResponsive.topSpacing(context)),
                    const LoginLogoWidget(),
                    const SizedBox(height: 48),
                    Text(
                      AppStrings.signUpTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tinos(
                        fontSize: isWide ? 20 : 16,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.signUpDescription,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.arimo(
                        fontSize: isWide ? 16 : 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textPrimary,
                      ).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    const SignUpFormWidget(),
                    const SizedBox(height: 24),
                    SignUpFooterWidget(
                      onSignIn: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

