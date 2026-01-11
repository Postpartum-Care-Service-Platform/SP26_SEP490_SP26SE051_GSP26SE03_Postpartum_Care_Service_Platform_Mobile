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
import '../widgets/notification_item.dart';
import '../../domain/entities/notification_entity.dart';

/// Notification screen
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.notificationBloc
        ..add(const NotificationLoadRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppStrings.notificationTitle,
            style: AppTextStyles.arimo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                // TODO: Show menu options
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
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
              if (state.notifications.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noNotifications,
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return _NotificationContent(
                notifications: state.notifications,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final List<NotificationEntity> notifications;

  const _NotificationContent({
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      children: [
        // Header with "Latest notification" and "Sort By"
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 14 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.latestNotification,
                style: AppTextStyles.arimo(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.sortBy,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18 * scale,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Notifications list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.borderLight,
            ),
            itemBuilder: (context, index) {
              final notification = notifications[index];
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
      ],
    );
  }
}
