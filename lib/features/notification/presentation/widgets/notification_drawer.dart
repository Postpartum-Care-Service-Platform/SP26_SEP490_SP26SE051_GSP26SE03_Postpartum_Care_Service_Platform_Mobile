import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../screens/notification_screen.dart';
import 'notification_item.dart';

/// Notification drawer widget
class NotificationDrawer extends StatelessWidget {
  const NotificationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) => InjectionContainer.notificationBloc
        ..add(const NotificationLoadRequested()),
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        backgroundColor: AppColors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.notificationTitle,
                      style: AppTextStyles.arimo(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is NotificationError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.message,
                              style: AppTextStyles.arimo(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<NotificationBloc>().add(
                                      const NotificationLoadRequested(),
                                    );
                              },
                              child: Text(AppStrings.retry),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is NotificationLoaded) {
                      final displayNotifications = state.notifications.take(5).toList();

                      return Column(
                        children: [
                          // Notifications list
                          Expanded(
                            child: displayNotifications.isEmpty
                                ? Center(
                                    child: Text(
                                      AppStrings.noNotifications,
                                      style: AppTextStyles.arimo(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20 * scale,
                                      vertical: 12 * scale,
                                    ),
                                    itemCount: displayNotifications.length,
                                    separatorBuilder: (context, index) => Divider(
                                      height: 1,
                                      color: AppColors.borderLight,
                                    ),
                                    itemBuilder: (context, index) {
                                      final notification = displayNotifications[index];
                                      return NotificationItem(
                                        notification: notification,
                                        onTap: () {
                                          if (!notification.isRead) {
                                            context.read<NotificationBloc>().add(
                                                  NotificationMarkAsRead(notification.id),
                                                );
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ),
                          // View All button - Always visible
                          Container(
                            padding: EdgeInsets.all(20 * scale),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.borderLight,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close drawer
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14 * scale,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12 * scale),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.viewAll,
                                  style: AppTextStyles.arimo(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
