import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/data/models/current_account_model.dart';
import '../widgets/account_summary_card.dart';
import '../widgets/account_details_section.dart';
import '../widgets/change_password_section.dart';
import '../widgets/account_error_view.dart';

/// Account details + change password screen
class AccountDetailsScreen extends StatefulWidget {
  final String userId;

  const AccountDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  CurrentAccountModel? _cachedAccount;

  @override
  void initState() {
    super.initState();
    // AuthBloc should be provided by parent (ProfileScreen)
    // Dispatch event to load account by ID
    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthGetAccountById(id: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppLoading.show(context, message: AppStrings.processing);
          } else {
            AppLoading.hide(context);
          }

          if (state is AuthError) {
            AppToast.showError(
              context,
              message: state.message,
            );
          }

          // Reload account by ID after password change success
          if (state is AuthChangePasswordSuccess) {
            // Show success toast immediately (loading is already hidden)
            AppToast.showSuccess(
              context,
              message: state.message,
            );
            // Reload account data after a short delay to let toast appear
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                final authBloc = context.read<AuthBloc>();
                authBloc.add(AuthGetAccountById(id: widget.userId));
              }
            });
          }

          // Cache account data when successfully loaded
          if (state is AuthGetAccountByIdSuccess) {
            _cachedAccount = state.account;
          }
        },
        child: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // Reload current account when leaving this screen
              // This ensures ProfileScreen still has AuthCurrentAccountLoaded state
              final authBloc = context.read<AuthBloc>();
              authBloc.add(const AuthLoadCurrentAccount());
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppAppBar(
              title: AppStrings.myAccount,
              centerTitle: true,
              titleFontSize: 20 * scale,
              titleFontWeight: FontWeight.w700,
            ),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // If we have cached account data, always show it (even if there's an error)
              // This ensures change password errors don't replace the form
              if (_cachedAccount != null) {
                return _AccountDetailsContent(account: _cachedAccount!);
              }

              if (state is AuthLoading && state is! AuthGetAccountByIdSuccess) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (state is AuthGetAccountByIdSuccess) {
                return _AccountDetailsContent(account: state.account);
              }

              if (state is AuthError) {
                return AccountErrorView(
                  message: state.message,
                  onRetry: () {
                    context.read<AuthBloc>().add(
                          AuthGetAccountById(id: widget.userId),
                        );
                  },
                );
              }

              return Center(
                child: Text(
                  AppStrings.noAccountData,
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
          ),
        ),
    );
  }
}

class _AccountDetailsContent extends StatelessWidget {
  final CurrentAccountModel account;

  const _AccountDetailsContent({required this.account});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16 * scale,
          right: 16 * scale,
          top: 16 * scale,
          bottom: 24 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player card
            AccountSummaryCard(account: account),
            SizedBox(height: 20 * scale),
            // Account details section
            AccountDetailsSection(account: account),
            SizedBox(height: 20 * scale),
            // Change password section
            const ChangePasswordSection(),
          ],
        ),
      ),
    );
  }
}
