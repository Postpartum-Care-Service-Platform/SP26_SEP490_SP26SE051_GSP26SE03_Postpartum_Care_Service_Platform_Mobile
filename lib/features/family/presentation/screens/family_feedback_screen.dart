// lib/features/family/presentation/screens/family_feedback_screen.dart
// NOTE: Ported from FeedbackFormView in Familystay FamilyPortal.tsx
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class FamilyFeedbackScreen extends StatefulWidget {
  const FamilyFeedbackScreen({super.key});

  @override
  State<FamilyFeedbackScreen> createState() => _FamilyFeedbackScreenState();
}

class _FamilyFeedbackScreenState extends State<FamilyFeedbackScreen> {
  int _rating = 0;

  String? _selectedStaff;
  String? _selectedService;

  final TextEditingController _feedbackController = TextEditingController();

  // Ported lists.
  final List<String> _staffList = const [
    'Điều dưỡng Mai',
    'Nữ hộ sinh Lan',
    'Điều dưỡng Hoa',
    'Điều dưỡng Phương',
  ];

  final List<String> _serviceList = const [
    'Chăm sóc mẹ sau sinh',
    'Chăm sóc bé',
    'Massage phục hồi',
    'Tư vấn dinh dưỡng',
    'Kiểm tra sức khỏe',
    'Yoga phục hồi',
    'Spa & Massage',
  ];

  final List<String> _quickComments = const [
    'Chăm sóc tận tình',
    'Nhân viên chuyên nghiệp',
    'Dịch vụ chất lượng',
    'Phòng ốc sạch sẽ',
    'Thực đơn ngon',
    'Cơ sở hiện đại',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _appendQuickComment(String comment) {
    final current = _feedbackController.text.trim();

    if (current.isEmpty) {
      _feedbackController.text = comment;
      return;
    }

    _feedbackController.text = '$current. $comment';
  }

  bool _canSubmit() {
    // Minimal validation.
    return _selectedStaff != null && _selectedService != null && _rating > 0;
  }

  void _submit() {
    if (!_canSubmit()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng chọn nhân viên, dịch vụ và đánh giá sao.',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gửi đánh giá thành công (mock).',
          style: AppTextStyles.arimo(color: AppColors.white),
        ),
        backgroundColor: AppColors.textPrimary,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.familyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white.withValues(alpha: 0.95),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Đánh giá',
          style: AppTextStyles.arimo(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Intro.
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
                    'Đánh giá dịch vụ',
                    style: AppTextStyles.arimo(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Chia sẻ trải nghiệm của bạn',
                    style: AppTextStyles.arimo(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Form container.
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
              child: Column(
                children: [
                  _FormBlock(
                    title: 'Chọn nhân viên',
                    child: _DropdownField(
                      hint: '-- Chọn nhân viên --',
                      value: _selectedStaff,
                      items: _staffList,
                      onChanged: (v) {
                        setState(() {
                          _selectedStaff = v;
                        });
                      },
                    ),
                  ),
                  _DividerLine(),
                  _FormBlock(
                    title: 'Chọn dịch vụ',
                    child: _DropdownField(
                      hint: '-- Chọn dịch vụ --',
                      value: _selectedService,
                      items: _serviceList,
                      onChanged: (v) {
                        setState(() {
                          _selectedService = v;
                        });
                      },
                    ),
                  ),
                  _DividerLine(),
                  _FormBlock(
                    title: 'Mức độ hài lòng',
                    centerTitle: true,
                    child: _StarRating(
                      rating: _rating,
                      onChanged: (v) {
                        setState(() {
                          _rating = v;
                        });
                      },
                    ),
                  ),
                  _DividerLine(),
                  _FormBlock(
                    title: 'Nhận xét nhanh',
                    subtitle: 'Nhấn để thêm vào nhận xét',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in _quickComments)
                          _QuickChip(
                            label: c,
                            onTap: () => _appendQuickComment(c),
                          ),
                      ],
                    ),
                  ),
                  _DividerLine(),
                  _FormBlock(
                    title: 'Nhận xét của bạn',
                    child: TextField(
                      controller: _feedbackController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Chia sẻ trải nghiệm của bạn...',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Submit.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.familyPrimary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Gửi đánh giá',
                  style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FormBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool centerTitle;

  const _FormBlock({
    required this.title,
    required this.child,
    this.subtitle,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.black.withValues(alpha: 0.06));
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          isExpanded: true,
          items: [
            for (final i in items)
              DropdownMenuItem(
                value: i,
                child: Text(
                  i,
                  style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _StarRating({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          InkWell(
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.star,
                size: 34,
                color: i <= rating ? const Color(0xFFFACC15) : const Color(0xFFD1D5DB),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.arimo(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
