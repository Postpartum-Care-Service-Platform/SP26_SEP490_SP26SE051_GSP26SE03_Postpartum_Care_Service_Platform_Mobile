// lib/features/family/presentation/screens/family_baby_daily_report_screen.dart
// NOTE: Baby report (1 time/day) for family side.
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class FamilyBabyDailyReportScreen extends StatefulWidget {
  const FamilyBabyDailyReportScreen({super.key});

  @override
  State<FamilyBabyDailyReportScreen> createState() => _FamilyBabyDailyReportScreenState();
}

class _FamilyBabyDailyReportScreenState extends State<FamilyBabyDailyReportScreen> {
  // Date of report.
  late DateTime _date;

  // Form controllers.
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _milkMlController = TextEditingController();
  final TextEditingController _peeCountController = TextEditingController();
  final TextEditingController _poopCountController = TextEditingController();
  final TextEditingController _sleepHoursController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Simple baby status.
  String _status = 'Tốt';

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();

    // NOTE: Mock default values.
    _temperatureController.text = '36.7';
    _weightController.text = '3.2';
    _milkMlController.text = '420';
    _peeCountController.text = '6';
    _poopCountController.text = '2';
    _sleepHoursController.text = '13';
    _notesController.text = '';
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _weightController.dispose();
    _milkMlController.dispose();
    _peeCountController.dispose();
    _poopCountController.dispose();
    _sleepHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày báo cáo',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _date = picked;
    });
  }

  void _submit() {
    // NOTE: This is a mock submit. Later: send to API.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã lưu báo cáo của bé (mock).',
          style: AppTextStyles.arimo(color: AppColors.white),
        ),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.familyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Báo cáo tình trạng bé',
          style: AppTextStyles.arimo(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month, color: AppColors.familyPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderCard(date: _date, onPickDate: _pickDate),
            const SizedBox(height: 12),

            _StatusCard(
              status: _status,
              onChanged: (v) {
                setState(() {
                  _status = v;
                });
              },
            ),
            const SizedBox(height: 12),

            _FormCard(
              children: [
                _LabeledField(
                  label: 'Nhiệt độ (°C)',
                  controller: _temperatureController,
                  keyboardType: TextInputType.number,
                ),
                _DividerLine(),
                _LabeledField(
                  label: 'Cân nặng (kg)',
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                ),
                _DividerLine(),
                _LabeledField(
                  label: 'Tổng lượng sữa (ml/ngày)',
                  controller: _milkMlController,
                  keyboardType: TextInputType.number,
                ),
                _DividerLine(),
                _LabeledField(
                  label: 'Số lần tè (lần/ngày)',
                  controller: _peeCountController,
                  keyboardType: TextInputType.number,
                ),
                _DividerLine(),
                _LabeledField(
                  label: 'Số lần ị (lần/ngày)',
                  controller: _poopCountController,
                  keyboardType: TextInputType.number,
                ),
                _DividerLine(),
                _LabeledField(
                  label: 'Tổng giấc ngủ (giờ/ngày)',
                  controller: _sleepHoursController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            const SizedBox(height: 12),

            _NotesCard(controller: _notesController),

            const SizedBox(height: 12),

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
                  'Lưu báo cáo',
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

class _HeaderCard extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPickDate;

  const _HeaderCard({required this.date, required this.onPickDate});

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Báo cáo 1 lần / ngày',
                  style: AppTextStyles.arimo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(date),
                  style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.familyPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Điền nhanh các chỉ số để nhân viên theo dõi.',
                  style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_month, size: 16),
            label: const Text('Đổi ngày'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.familyPrimary,
              side: BorderSide(color: AppColors.borderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final wd = weekdays[dt.weekday % 7];
    return '$wd, ${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final ValueChanged<String> onChanged;

  const _StatusCard({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = ['Tốt', 'Bình thường', 'Cần theo dõi'];

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
            'Tình trạng',
            style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opt in options)
                InkWell(
                  onTap: () => onChanged(opt),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: status == opt ? AppColors.familyPrimary : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      opt,
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: status == opt ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.black.withValues(alpha: 0.06));
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final TextEditingController controller;

  const _NotesCard({required this.controller});

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
            'Ghi chú',
            style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Ghi chú thêm về tình trạng bé...',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
