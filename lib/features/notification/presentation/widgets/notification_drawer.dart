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

/// Notification drawer widget - Simplified version
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
              // Simple Header
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.notificationTitle,
                      style: AppTextStyles.arimo(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.borderLight),
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
                        child: Padding(
                          padding: EdgeInsets.all(24 * scale),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.message,
                                style: AppTextStyles.arimo(
                                  fontSize: 14 * scale,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16 * scale),
                              TextButton(
                                onPressed: () {
                                  context.read<NotificationBloc>().add(
                                        const NotificationLoadRequested(),
                                      );
                                },
                                child: Text(AppStrings.retry),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is NotificationLoaded) {
                      final displayNotifications = state.notifications.take(5).toList();

                      if (displayNotifications.isEmpty) {
                        return Center(
                          child: Text(
                            AppStrings.noNotifications,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale,
                                vertical: 8 * scale,
                              ),
                              itemCount: displayNotifications.length,
                              separatorBuilder: (context, index) => SizedBox(height: 8 * scale),
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
                          // Simple View All button
                          Padding(
                            padding: EdgeInsets.all(16 * scale),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12 * scale),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12 * scale),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.viewAll,
                                  style: AppTextStyles.arimo(
                                    fontSize: 15 * scale,
                                    fontWeight: FontWeight.w600,
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
