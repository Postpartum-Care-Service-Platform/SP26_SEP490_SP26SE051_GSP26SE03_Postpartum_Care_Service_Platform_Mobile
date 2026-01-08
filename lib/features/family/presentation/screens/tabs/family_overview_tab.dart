// lib/features/family/presentation/screens/tabs/family_overview_tab.dart
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class FamilyOverviewTab extends StatelessWidget {
  const FamilyOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _WelcomeCard(),
          SizedBox(height: 12),
          _StatsGrid(),
          SizedBox(height: 12),
          _TodayActivityCard(),
          SizedBox(height: 12),
          _SupportCard(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, gia đình Trần Thị B!',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chúc mừng bé yêu đã chào đời. Chúng tôi luôn đồng hành cùng gia đình.',
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            title: 'Ngày ở lại',
            value: '3',
            suffix: '/ 28',
            valueColor: AppColors.familyPrimary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Mẹ',
            value: 'Tốt ✓',
            valueColor: Color(0xFF1B7F3A),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Bé',
            value: 'Khỏe ✓',
            valueColor: Color(0xFF1B7F3A),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.valueColor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTextStyles.arimo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayActivityCard extends StatelessWidget {
  const _TodayActivityCard();

  static const _items = [
    {
      'time': '08:00',
      'activity': 'Kiểm tra sức khỏe mẹ',
      'staff': 'Điều dưỡng Mai',
      'icon': '✅',
    },
    {
      'time': '09:00',
      'activity': 'Chăm sóc bé - Tắm rửa',
      'staff': 'Nữ hộ sinh Lan',
      'icon': '✅',
    },
    {
      'time': '11:00',
      'activity': 'Massage phục hồi',
      'staff': 'Điều dưỡng Mai',
      'icon': '⏰',
    },
    {
      'time': '12:00',
      'activity': 'Bữa trưa',
      'staff': 'Bếp',
      'icon': '🍽️',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Hoạt động hôm nay',
                    style: AppTextStyles.arimo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.05),
          ),
          for (final item in _items) _ActivityRow(item: item),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Map<String, String> item;

  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['icon'] ?? '•', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['activity'] ?? '',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item['time'] ?? '',
                        style: AppTextStyles.arimo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.familyPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['staff'] ?? '',
                    style: AppTextStyles.arimo(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.familyPrimary,
            Color(0xFFFFA952),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cần hỗ trợ?',
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Liên hệ với chúng tôi bất cứ lúc nào',
            style: AppTextStyles.arimo(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Mở chat (sẽ tích hợp sau).',
                      style: AppTextStyles.arimo(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.textPrimary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.familyPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Nhắn tin ngay',
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.familyPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
