import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, this.userName = 'Mom'});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.goodMorning,
              style: AppTextStyles.arimo(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              userName,
              style: AppTextStyles.tinos(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: Colors.grey[800]),
          onPressed: () {
            // TODO: Navigate to notifications screen
          },
        ),
      ],
    );
  }
}

