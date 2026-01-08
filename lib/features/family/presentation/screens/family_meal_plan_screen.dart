// lib/features/family/presentation/screens/family_meal_plan_screen.dart
// NOTE: Family meal planning screen with drag & drop.
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../meal_plan/domain/entities/daily_meal_plan.dart';
import '../../../meal_plan/domain/entities/meal_item.dart';
import '../../../meal_plan/domain/entities/meal_slot.dart';

/// FamilyMealPlanScreen
/// - Drag meals from "library" into meal slots (breakfast/lunch/dinner/snack)
/// - Also supports moving between slots and removing.
class FamilyMealPlanScreen extends StatefulWidget {
  final String familyId;

  const FamilyMealPlanScreen({
    super.key,
    required this.familyId,
  });

  @override
  State<FamilyMealPlanScreen> createState() => _FamilyMealPlanScreenState();
}

class _FamilyMealPlanScreenState extends State<FamilyMealPlanScreen> {
  // Selected date.
  late DateTime _date;

  // Plan state.
  late DailyMealPlan _plan;

  // Mock meal library.
  late final List<MealItem> _library;

  @override
  void initState() {
    super.initState();

    _date = DateTime.now();
    _plan = DailyMealPlan.empty(familyId: widget.familyId, date: _date);

    _library = const [
      MealItem(id: 'm1', name: 'Cháo gà', description: 'Cháo gà nóng, dễ tiêu'),
      MealItem(id: 'm2', name: 'Canh rau ngót', description: 'Rau ngót nấu thịt bằm'),
      MealItem(id: 'm3', name: 'Cá hồi áp chảo', description: 'Giàu Omega-3'),
      MealItem(id: 'm4', name: 'Sữa hạt', description: 'Hạt óc chó + hạnh nhân'),
      MealItem(id: 'm5', name: 'Salad trái cây', description: 'Chuối + táo + kiwi'),
      MealItem(id: 'm6', name: 'Cơm gạo lứt', description: 'Ăn kèm thịt nạc'),
      MealItem(id: 'm7', name: 'Soup bí đỏ', description: 'Bổ sung chất xơ'),
      MealItem(id: 'm8', name: 'Trứng hấp', description: 'Mềm, giàu đạm'),
    ];
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
      _plan = DailyMealPlan.empty(familyId: widget.familyId, date: _date);
    });
  }

  void _applyDrop(_MealDragPayload payload, MealSlot targetSlot) {
    setState(() {
      if (payload.sourceSlot == null) {
        // From library.
        _plan = _plan.addMealToSlot(targetSlot, payload.meal);
        return;
      }

      // Move between slots.
      if (payload.sourceSlot == targetSlot) {
        return;
      }

      _plan = _plan.moveMeal(fromSlot: payload.sourceSlot!, mealId: payload.meal.id, toSlot: targetSlot);
    });
  }

  void _removeFromSlot(MealSlot slot, MealItem meal) {
    setState(() {
      _plan = _plan.removeMealFromSlot(slot, meal.id);
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
          'Thực đơn dinh dưỡng',
          style: AppTextStyles.arimo(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month, color: AppColors.familyPrimary),
            tooltip: 'Chọn ngày',
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

            // Meal plan slots.
            for (final slot in MealSlot.values) ...[
              _MealSlotDropZone(
                slot: slot,
                meals: _plan.slots[slot] ?? const [],
                onAccept: (payload) => _applyDrop(payload, slot),
                onRemove: (meal) => _removeFromSlot(slot, meal),
              ),
              const SizedBox(height: 12),
            ],

            // Library.
            _LibrarySection(library: _library),
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
                  'Thực đơn dinh dưỡng',
                  style: AppTextStyles.arimo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kéo thả món ăn vào từng bữa',
                  style: AppTextStyles.arimo(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatDate(date),
                  style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.familyPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_month, size: 16),
            label: const Text('Đổi ngày'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.familyPrimary,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

class _MealSlotDropZone extends StatelessWidget {
  final MealSlot slot;
  final List<MealItem> meals;
  final ValueChanged<_MealDragPayload> onAccept;
  final ValueChanged<MealItem> onRemove;

  const _MealSlotDropZone({
    required this.slot,
    required this.meals,
    required this.onAccept,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<_MealDragPayload>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.familyPrimary : AppColors.borderLight,
              width: isActive ? 2 : 1,
            ),
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
                    isActive ? 'Thả vào đây' : 'Chưa có món nào',
                    style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final meal in meals)
                      _PlannedMealChip(
                        meal: meal,
                        slot: slot,
                        onRemove: () => onRemove(meal),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlannedMealChip extends StatelessWidget {
  final MealItem meal;
  final MealSlot slot;
  final VoidCallback onRemove;

  const _PlannedMealChip({
    required this.meal,
    required this.slot,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<_MealDragPayload>(
      data: _MealDragPayload(meal: meal, sourceSlot: slot),
      feedback: Material(
        color: Colors.transparent,
        child: _ChipBody(
          label: meal.name,
          isDragging: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _ChipBody(label: meal.name),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _ChipBody(label: meal.name),
          Positioned(
            right: -6,
            top: -6,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarySection extends StatelessWidget {
  final List<MealItem> library;

  const _LibrarySection({required this.library});

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
          Text(
            'Kho món ăn',
            style: AppTextStyles.arimo(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Giữ và kéo món ăn để thả vào bữa',
            style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = (width - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final meal in library)
                    SizedBox(
                      width: itemWidth,
                      child: Draggable<_MealDragPayload>(
                        data: _MealDragPayload(meal: meal, sourceSlot: null),
                        feedback: Material(
                          color: Colors.transparent,
                          child: _LibraryCard(meal: meal, isDragging: true),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: _LibraryCard(meal: meal),
                        ),
                        child: _LibraryCard(meal: meal),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final MealItem meal;
  final bool isDragging;

  const _LibraryCard({required this.meal, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.familyBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDragging ? AppColors.familyPrimary : AppColors.borderLight,
          width: isDragging ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal.name,
            style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            meal.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.drag_indicator, size: 16, color: AppColors.familyPrimary),
              const SizedBox(width: 6),
              Text(
                'Kéo thả',
                style: AppTextStyles.arimo(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.familyPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipBody extends StatelessWidget {
  final String label;
  final bool isDragging;

  const _ChipBody({required this.label, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDragging ? AppColors.familyPrimary : AppColors.familyPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.familyPrimary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: AppTextStyles.arimo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDragging ? AppColors.white : AppColors.familyPrimary,
        ),
      ),
    );
  }
}

class _MealDragPayload {
  final MealItem meal;

  /// null means from library.
  final MealSlot? sourceSlot;

  const _MealDragPayload({
    required this.meal,
    required this.sourceSlot,
  });
}
