import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/appointment/presentation/screens/appointment_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/chat/presentation/screens/conversation_list_screen.dart';
import '../../features/notification/presentation/widgets/notification_drawer.dart';
import 'app_bottom_navigation_bar.dart';

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
  late AppBottomTab _currentTab;
  late final PageController _pageController;

  int get _currentIndex => _currentTab.index;

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
    _currentTab = widget.initialTab ?? AppBottomTab.home;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(AppBottomTab tab, BuildContext context) {
    final index = tab.index;
    if (index < 0 || index >= _screens.length) return;
    if (tab == _currentTab) return;

    setState(() {
      _currentTab = tab;
    });

    // Silently reload current account when switching to services tab
    if (tab == AppBottomTab.services) {
      context.read<AuthBloc>().add(const AuthLoadCurrentAccount());
    }

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.authBloc
        ..add(const AuthLoadCurrentAccount()),
      child: Builder(
        builder: (blocContext) => Scaffold(
          backgroundColor: AppColors.background,
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (index < 0 || index >= AppBottomTab.values.length) return;
              final newTab = AppBottomTab.values[index];
              setState(() {
                _currentTab = newTab;
              });
              
              // Silently reload current account when switching to services tab
              if (newTab == AppBottomTab.services) {
                blocContext.read<AuthBloc>().add(const AuthLoadCurrentAccount());
              }
            },
            children: _screens,
          ),
          bottomNavigationBar: Builder(
            builder: (navContext) => AppBottomNavigationBar(
              currentTab: _currentTab,
              onTabSelected: (tab) => _onTabSelected(tab, blocContext),
            ),
          ),
          endDrawer: const NotificationDrawer(),
        ),
      ),
    );
  }
}

