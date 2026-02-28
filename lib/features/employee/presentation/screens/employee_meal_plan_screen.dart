// lib/features/employee/presentation/screens/employee_meal_plan_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/employee_scaffold.dart';

class EmployeeMealPlanScreen extends StatefulWidget {
  const EmployeeMealPlanScreen({super.key});

  @override
  State<EmployeeMealPlanScreen> createState() => _EmployeeMealPlanScreenState();
}

class _EmployeeMealPlanScreenState extends State<EmployeeMealPlanScreen> {
  int? _selectedFamilyId;

  static const _families = [
    {'id': 1, 'name': 'Gia đình Trần Thị B', 'room': 'Phòng 101'},
    {'id': 2, 'name': 'Gia đình Nguyễn Văn C', 'room': 'Phòng 203'},
    {'id': 3, 'name': 'Gia đình Lê Thị D', 'room': 'Phòng 305'},
  ];

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return EmployeeScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Bữa ăn của gia đình',
          style: AppTextStyles.arimo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              _HeaderCard(
                title: 'Chọn bữa ăn 🍽️',
                subtitle: 'Hỗ trợ gia đình chọn thực đơn',
              ),
              const SizedBox(height: 12),
              Container(
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Chọn gia đình',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedFamilyId,
                      items: [
                        for (final f in _families)
                          DropdownMenuItem<int>(
                            value: f['id'] as int,
                            child: Text(
                              '${f['name']} - ${f['room']}',
                              style: AppTextStyles.arimo(),
                            ),
                          )
                      ],
                      onChanged: (v) => setState(() => _selectedFamilyId = v),
                      decoration: InputDecoration(
                        hintText: '— Chọn gia đình —',
                        hintStyle: AppTextStyles.arimo(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _selectedFamilyId == null
                            ? 'Vui lòng chọn một hộ gia đình để xem thực đơn.'
                            : 'Tính năng đang được phát triển...\n(Bên React cũng đang để placeholder)',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
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
