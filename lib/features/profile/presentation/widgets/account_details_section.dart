import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/data/models/current_account_model.dart';
import 'account_info_row.dart';

/// Account details section - displays phone, status, dates
class AccountDetailsSection extends StatelessWidget {
  final CurrentAccountModel account;

  const AccountDetailsSection({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppWidgets.sectionHeader(
          context,
          title: AppStrings.accountDetailsTitle,
        ),
        AppWidgets.sectionContainer(
          context,
          padding: EdgeInsets.symmetric(
            vertical: 4 * scale,
          ),
          children: [
            AccountInfoRow(
              label: AppStrings.accountPhoneNumber,
              value: account.phone,
            ),
            AccountInfoRow(
              label: AppStrings.accountStatus,
              value: account.isActive
                  ? AppStrings.accountStatusActive
                  : AppStrings.accountStatusLocked,
            ),
            AccountInfoRow(
              label: AppStrings.accountCreatedAt,
              value: '${account.createdAt.toLocal()}'.split('.').first,
            ),
            AccountInfoRow(
              label: AppStrings.accountUpdatedAt,
              value: '${account.updatedAt.toLocal()}'.split('.').first,
            ),
          ],
        ),
      ],
    );
  }
}
