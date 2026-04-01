import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          AppAssets.theJoyfulNestBrand,
          width: 122 * scale,
          height: 30 * scale,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            int unreadCount = 0;
            if (state is NotificationLoaded) {
              unreadCount = state.unreadCount;
            }

            final icon = Padding(
              padding: EdgeInsets.all(4 * scale),
              child: SvgPicture.asset(
                AppAssets.notificationBell,
                colorFilter: ColorFilter.mode(
                  Colors.grey[800]!,
                  BlendMode.srcIn,
                ),
                width: 24 * scale,
                height: 24 * scale,
              ),
            );

            return IconButton(
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.red,
                      child: icon,
                    )
                  : icon,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
      ],
    );
  }
}
