import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/appointment/presentation/screens/appointment_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/chat/presentation/screens/conversation_list_screen.dart';
import '../../features/notification/presentation/widgets/notification_drawer.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/notification/presentation/bloc/notification_event.dart';
import 'app_bottom_navigation_bar.dart';

class ToggleBottomNavNotification extends Notification {
  final bool show;
  const ToggleBottomNavNotification({required this.show});
}

class AppScaffold extends StatefulWidget {
  final AppBottomTab? initialTab;

  const AppScaffold({
    super.key,
    this.initialTab,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  static const List<AppBottomTab> _customerTabs = [
    AppBottomTab.home,
    AppBottomTab.appointment,
    AppBottomTab.services,
    AppBottomTab.chat,
    AppBottomTab.profile,
  ];

  late AppBottomTab _currentTab;
  late final PageController _pageController;
  bool _showBottomNav = true;

  int get _currentIndex {
    final index = _customerTabs.indexOf(_currentTab);
    return index >= 0 ? index : 0;
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    AppointmentScreen(),
    ServicesScreen(),
    ConversationListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Trigger initial account load
    context.read<AuthBloc>().add(const AuthLoadCurrentAccount());
    
    // Trigger initial notification load for badges
    context.read<NotificationBloc>().add(const NotificationLoadRequested());

    final initialTab = widget.initialTab ?? AppBottomTab.home;
    _currentTab = _customerTabs.contains(initialTab)
        ? initialTab
        : AppBottomTab.home;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(AppBottomTab tab, BuildContext context) {
    final index = _customerTabs.indexOf(tab);
    if (index < 0 || index >= _screens.length) return;

    if (tab == _currentTab) return;

    setState(() {
      _currentTab = tab;
    });

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ToggleBottomNavNotification>(
      onNotification: (notification) {
        if (mounted) {
          setState(() {
            _showBottomNav = notification.show;
          });
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (index < 0 || index >= _customerTabs.length) return;
          final newTab = _customerTabs[index];
          setState(() {
            _currentTab = newTab;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _showBottomNav
          ? AppBottomNavigationBar(
              currentTab: _currentTab,
              onTabSelected: (tab) => _onTabSelected(tab, context),
            )
          : null,
      endDrawer: const NotificationDrawer(),
    ),);
  }
}

