import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_header.dart';
import '../widgets/upcoming_schedule_card.dart';
import '../widgets/promotion_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthRepository _authRepository = InjectionContainer.authRepository;
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentAccount();
  }

  Future<void> _loadCurrentAccount() async {
    try {
      final user = await _authRepository.getCurrentAccount();
      
      if (mounted) {
        setState(() {
          _username = user.username;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _username = 'Mom'; // Fallback to default
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: AppResponsive.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top inset is already handled by SafeArea.
            const SizedBox(height: 8),
            HomeHeader(userName: _username, isLoading: _isLoading),
            const SizedBox(height: 32),

            // Quick Actions Section
            const SectionHeader(title: AppStrings.quickActions),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              QuickActionCard(icon: Icons.spa_outlined, title: AppStrings.spaAndCare, onTap: () {}),
              QuickActionCard(icon: Icons.child_care_outlined, title: AppStrings.babyActivities, onTap: () {}),
              QuickActionCard(icon: Icons.restaurant_menu_outlined, title: AppStrings.nutritionMenu, onTap: () {}),
              QuickActionCard(icon: Icons.map_outlined, title: AppStrings.resortMap, onTap: () {}),
            ],
          ),
          const SizedBox(height: 32),

          // Upcoming Schedule Section
          SectionHeader(
            title: AppStrings.upcomingSchedule,
            actionText: AppStrings.viewAll,
            onActionPressed: () {},
          ),
          const SizedBox(height: 16),
          const UpcomingScheduleCard(
            time: '10:00 AM',
            title: 'Yoga cho mẹ bầu',
            location: 'Phòng Zen',
          ),
          const SizedBox(height: 32),

          // Promotions Section
          SectionHeader(
            title: AppStrings.promotions,
            actionText: AppStrings.viewAll,
            onActionPressed: () {},
          ),
          const SizedBox(height: 16),
          // Note: You need to add a placeholder image at 'assets/images/promotion_banner.jpg'
          PromotionBanner(
            title: 'Ưu đãi 20% Spa',
            subtitle: 'Gói phục hồi sau sinh',
            imagePath: AppAssets.promotionBanner,
            onTap: () {},
          ),
          const SizedBox(height: 24),
        ],
      ),
    )
    );
  }
}
