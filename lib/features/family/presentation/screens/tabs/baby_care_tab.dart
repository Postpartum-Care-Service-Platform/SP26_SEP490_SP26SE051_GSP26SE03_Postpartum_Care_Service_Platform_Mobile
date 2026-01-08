// lib/features/family/presentation/screens/tabs/baby_care_tab.dart
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

import '../family_baby_daily_report_screen.dart';

class BabyCareTab extends StatelessWidget {
  const BabyCareTab({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: Tab is embedded inside FamilyPortal, so we render the report UI directly.
    return const FamilyBabyDailyReportScreen();
  }
}
