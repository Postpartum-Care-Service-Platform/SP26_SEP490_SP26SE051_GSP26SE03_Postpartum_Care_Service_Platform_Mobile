import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_loading_state.dart';
import '../widgets/notification_error_state.dart';
import '../widgets/notification_list_empty_state.dart';
import '../widgets/notification_header.dart';
import '../widgets/notification_list.dart';
import '../widgets/notification_mark_all_read_button.dart';
import '../../../../core/widgets/app_app_bar.dart';

/// Notification screen with modern design
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

enum NotificationFilter {
  all,
  unread,
  read,
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationFilter _currentFilter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.notificationBloc
        ..add(const NotificationLoadRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: AppStrings.notificationTitle,
          centerTitle: true,
          titleFontSize: 20,
          titleFontWeight: FontWeight.w700,
          actions: const [
            NotificationMarkAllReadButton(),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const NotificationLoadingState();
            }

            if (state is NotificationError) {
              return NotificationErrorState(message: state.message);
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const NotificationListEmptyState();
              }

              return _NotificationContent(
                notifications: state.notifications,
                unreadCount: state.unreadCount,
                currentFilter: _currentFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _currentFilter = filter;
                  });
                },
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
  final int unreadCount;
  final NotificationFilter currentFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  const _NotificationContent({
    required this.notifications,
    required this.unreadCount,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NotificationHeader(
          currentFilter: currentFilter,
          onFilterChanged: onFilterChanged,
          unreadCount: unreadCount,
        ),
        Expanded(
          child: NotificationList(
            notifications: notifications,
            currentFilter: currentFilter,
          ),
        ),
      ],
    );
  }
}
