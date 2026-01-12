import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/appointment/presentation/screens/appointment_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/notification/presentation/widgets/notification_drawer.dart';
import 'app_bottom_navigation_bar.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  AppBottomTab _currentTab = AppBottomTab.home;
  late final PageController _pageController;

  int get _currentIndex => _currentTab.index;

  final List<Widget> _screens = const [
    HomeScreen(),
    AppointmentScreen(),
    ServicesScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(AppBottomTab tab) {
    final index = tab.index;
    if (index < 0 || index >= _screens.length) return;
    if (tab == _currentTab) return;

    setState(() {
      _currentTab = tab;
    });

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (index < 0 || index >= AppBottomTab.values.length) return;
          setState(() {
            _currentTab = AppBottomTab.values[index];
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentTab: _currentTab,
        onTabSelected: _onTabSelected,
      ),
      endDrawer: const NotificationDrawer(),
    );
  }
}

