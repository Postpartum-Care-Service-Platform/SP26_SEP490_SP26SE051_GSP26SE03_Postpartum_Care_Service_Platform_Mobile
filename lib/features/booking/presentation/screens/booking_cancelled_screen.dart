import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCancelledScreen extends StatelessWidget {
  final String? message;

  const BookingCancelledScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 86 * scale,
                height: 86 * scale,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 44 * scale,
                  color: AppColors.red,
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                AppStrings.bookingCancelledTitle,
                style: AppTextStyles.arimo(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * scale),
              Text(
                message?.trim().isNotEmpty == true
                    ? message!.trim()
                    : AppStrings.bookingCancelledSubtitle,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28 * scale),
              AppWidgets.primaryButton(
                text: AppStrings.bookingCancelledBackToServices,
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  String? role;
                  String? memberType;

                  if (authState is AuthSuccess) {
                    role = authState.user?.role.toLowerCase();
                    memberType = authState.user?.memberType?.toLowerCase();
                  } else if (authState is AuthCurrentAccountLoaded) {
                    role = authState.account.roleName.toLowerCase();
                    memberType =
                        authState.account.memberType?.toLowerCase() ??
                        authState.account.ownerProfile?.memberTypeName
                            ?.toLowerCase();
                  } else if (authState is AuthGetAccountByIdSuccess) {
                    role = authState.account.roleName.toLowerCase();
                    memberType =
                        authState.account.memberType?.toLowerCase() ??
                        authState.account.ownerProfile?.memberTypeName
                            ?.toLowerCase();
                  }

                  final isEmployee =
                      role == 'staff' ||
                      role == 'manager' ||
                      role == 'admin' ||
                      role == 'homestaff' ||
                      (memberType != null &&
                          (memberType.contains('staff') ||
                              memberType.contains('nurse')));

                  if (isEmployee) {
                    AppRouter.pushAndRemoveUntil(
                      context,
                      AppRoutes.employeePortal,
                    );
                  } else {
                    AppRouter.pushAndRemoveUntil(context, AppRoutes.home);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
