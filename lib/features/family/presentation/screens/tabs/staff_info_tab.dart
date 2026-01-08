// lib/features/family/presentation/screens/tabs/staff_info_tab.dart
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class StaffInfoTab extends StatefulWidget {
  const StaffInfoTab({super.key});

  @override
  State<StaffInfoTab> createState() => _StaffInfoTabState();
}

class _StaffInfoTabState extends State<StaffInfoTab> {
  // Selected date in ISO format yyyy-mm-dd.
  late String _selectedDate;

  @override
  void initState() {
    super.initState();

    // Default date matches the TS mock.
    _selectedDate = '2024-11-25';
  }

  // NOTE: Ported mock data from FamilyPortal.tsx.
  List<_StaffMember> _getStaffByDate(String date) {
    final schedule = <String, List<_StaffMember>>{
      '2024-11-25': const [
        _StaffMember(
          name: 'Trần Thị Mai',
          role: 'Điều dưỡng chính',
          experience: '8 năm',
          specialty: 'Chăm sóc sau sinh',
          shift: 'Ca sáng',
        ),
        _StaffMember(
          name: 'Nguyễn Thị Lan',
          role: 'Nữ hộ sinh',
          experience: '6 năm',
          specialty: 'Chăm sóc trẻ sơ sinh',
          shift: 'Ca sáng',
        ),
        _StaffMember(
          name: 'Lê Thị Hoa',
          role: 'Điều dưỡng',
          experience: '5 năm',
          specialty: 'Massage phục hồi',
          shift: 'Ca chiều',
        ),
      ],
    };

    return schedule[date] ?? schedule['2024-11-25'] ?? const [];
  }

  Future<void> _pickDate() async {
    // Parse current date.
    final current = DateTime.tryParse(_selectedDate) ?? DateTime.now();

    // Show date picker.
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày',
    );

    if (picked == null) {
      return;
    }

    // Convert to ISO yyyy-mm-dd.
    final iso = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

    setState(() {
      _selectedDate = iso;
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final staff = _getStaffByDate(_selectedDate);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card.
          Container(
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
                  'Đội ngũ chăm sóc',
                  style: AppTextStyles.arimo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.familyBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 20, color: AppColors.familyPrimary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedDate,
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Date badge (simple).
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _formatDateVi(_selectedDate),
                style: AppTextStyles.arimo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Staff list.
          for (final member in staff) ...[
            _StaffCard(member: member),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatDateVi(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) {
      return isoDate;
    }

    // Minimal formatting without intl dependency.
    // Example: "T2, 25 thg 11".
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final wd = weekdays[dt.weekday % 7];

    return '$wd, ${dt.day} thg ${dt.month}';
  }
}

class _StaffCard extends StatelessWidget {
  final _StaffMember member;

  const _StaffCard({required this.member});

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.familyPrimary, Color(0xFFFFA952)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  member.name.isNotEmpty ? member.name.characters.first : '?',
                  style: AppTextStyles.arimo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.arimo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.role,
                      style: AppTextStyles.arimo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.familyPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _InfoLine(icon: Icons.menu_book, text: member.experience),
                    const SizedBox(height: 6),
                    _InfoLine(icon: Icons.work_outline, text: member.specialty),
                    const SizedBox(height: 6),
                    _InfoLine(icon: Icons.access_time, text: member.shift, isEmphasis: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Mở chat với ${member.name} (sẽ tích hợp sau).',
                      style: AppTextStyles.arimo(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.textPrimary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.familyPrimary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Nhắn tin',
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isEmphasis;

  const _InfoLine({
    required this.icon,
    required this.text,
    this.isEmphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.familyPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 12,
              fontWeight: isEmphasis ? FontWeight.w600 : FontWeight.w500,
              color: isEmphasis ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffMember {
  final String name;
  final String role;
  final String experience;
  final String specialty;
  final String shift;

  const _StaffMember({
    required this.name,
    required this.role,
    required this.experience,
    required this.specialty,
    required this.shift,
  });
}
