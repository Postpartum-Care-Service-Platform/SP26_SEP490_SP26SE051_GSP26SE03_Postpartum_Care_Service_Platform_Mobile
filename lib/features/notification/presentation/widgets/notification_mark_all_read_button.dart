import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

/// Mark all notifications as read button widget
class NotificationMarkAllReadButton extends StatelessWidget {
  const NotificationMarkAllReadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoaded && state.unreadCount > 0) {
          return IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${state.unreadCount > 9 ? '9+' : state.unreadCount}',
                      style: AppTextStyles.arimo(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              context.read<NotificationBloc>().add(
                    const NotificationMarkAllAsRead(),
                  );
            },
            tooltip: 'Đánh dấu tất cả đã đọc',
            splashRadius: 24,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
