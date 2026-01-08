// lib/features/family/presentation/screens/family_daily_meal_screen.dart
// NOTE: Read-only "thực đơn trong ngày" view (from drag-drop plan).
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../meal_plan/domain/entities/daily_meal_plan.dart';
import '../../../meal_plan/domain/entities/meal_item.dart';
import '../../../meal_plan/domain/entities/meal_slot.dart';

class FamilyDailyMealScreen extends StatefulWidget {
  final String familyId;

  const FamilyDailyMealScreen({
    super.key,
    required this.familyId,
  });

  @override
  State<FamilyDailyMealScreen> createState() => _FamilyDailyMealScreenState();
}

class _FamilyDailyMealScreenState extends State<FamilyDailyMealScreen> {
  late DateTime _date;
  late DailyMealPlan _plan;

  @override
  void initState() {
    super.initState();

    _date = DateTime.now();

    // NOTE: For now, we use a mock plan.
    // Later: load from repository by familyId + date.
    _plan = _mockPlan(familyId: widget.familyId, date: _date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _date = picked;
      _plan = _mockPlan(familyId: widget.familyId, date: _date);
    });
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
          'Thực đơn trong ngày',
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
            _Header(date: _date),
            const SizedBox(height: 12),

            for (final slot in MealSlot.values) ...[
              _MealSlotCard(slot: slot, meals: _plan.slots[slot] ?? const []),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  DailyMealPlan _mockPlan({required String familyId, required DateTime date}) {
    // NOTE: This is only for UI wiring. The real data source will come later.
    final plan = DailyMealPlan.empty(familyId: familyId, date: date);

    return plan.copyWith(
      slots: {
        MealSlot.breakfast: const [
          MealItem(id: 'm1', name: 'Cháo gà', description: 'Cháo gà nóng, dễ tiêu'),
          MealItem(id: 'm4', name: 'Sữa hạt', description: 'Hạt óc chó + hạnh nhân'),
        ],
        MealSlot.lunch: const [
          MealItem(id: 'm6', name: 'Cơm gạo lứt', description: 'Ăn kèm thịt nạc'),
          MealItem(id: 'm2', name: 'Canh rau ngót', description: 'Rau ngót nấu thịt bằm'),
        ],
        MealSlot.dinner: const [
          MealItem(id: 'm3', name: 'Cá hồi áp chảo', description: 'Giàu Omega-3'),
          MealItem(id: 'm7', name: 'Soup bí đỏ', description: 'Bổ sung chất xơ'),
        ],
        MealSlot.snack: const [
          MealItem(id: 'm5', name: 'Salad trái cây', description: 'Chuối + táo + kiwi'),
        ],
      },
    );
  }
}

class _Header extends StatelessWidget {
  final DateTime date;

  const _Header({required this.date});

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
            'Thực đơn hôm nay',
            style: AppTextStyles.arimo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(date),
            style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.familyPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Dữ liệu hiện đang là mock. Sau khi nối API, màn này sẽ hiển thị đúng theo kế hoạch kéo-thả.',
            style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
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

class _MealSlotCard extends StatelessWidget {
  final MealSlot slot;
  final List<MealItem> meals;

  const _MealSlotCard({required this.slot, required this.meals});

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  slot.labelVi,
                  style: AppTextStyles.arimo(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.familyPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${meals.length} món',
                  style: AppTextStyles.arimo(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.familyPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (meals.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.familyBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'Chưa có món nào',
                style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            )
          else
            Column(
              children: [
                for (final m in meals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _MealRow(meal: m),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final MealItem meal;

  const _MealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.familyBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu, size: 18, color: AppColors.familyPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.description,
                  style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
