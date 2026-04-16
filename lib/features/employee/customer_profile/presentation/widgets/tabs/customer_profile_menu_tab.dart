import 'package:flutter/material.dart';
import '../../../../../services/data/models/menu_model.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/utils/app_text_styles.dart';
import '../../../../../services/data/models/menu_record_model.dart';

class CustomerProfileMenuTab extends StatelessWidget {
  final Future<List<MenuRecordModel>> future;
  final double scale;
  final String Function(DateTime) fmtDate;
  final Widget filterWidget;
  final void Function(int) onViewDetails;
  final void Function(MenuRecordModel) onEdit;
  final void Function(MenuRecordModel) onDelete;
  final Map<int, MenuModel>? menuDetails;

  const CustomerProfileMenuTab({
    super.key,
    required this.future,
    required this.scale,
    required this.fmtDate,
    required this.filterWidget,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
    this.menuDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filterWidget,
        Expanded(
          child: FutureBuilder<List<MenuRecordModel>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Không tải được Thực đơn:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
                  ),
                );
              }
              final records = snapshot.data ?? const [];
              if (records.isEmpty) {
                return Center(
                  child: Text(
                    'Không có Thực đơn theo bộ lọc.',
                    style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
                  ),
                );
              }

              // Sorting logic: Date descending, then Meal Type ascending
              records.sort((a, b) {
                // 1. Compare dates
                int dateComp = b.date.compareTo(a.date);
                if (dateComp != 0) return dateComp;

                // 2. Compare meal types if same date
                const mealPriority = {'Sáng': 1, 'Trưa': 2, 'Chiều': 3, 'Tối': 4};
                
                String getMeal(String name) {
                  final p = name.split(' - ');
                  if (p.length > 1) {
                    final m = p.last.trim();
                    if (m.contains('Sáng')) return 'Sáng';
                    if (m.contains('Trưa')) return 'Trưa';
                    if (m.contains('Chiều')) return 'Chiều';
                    if (m.contains('Tối')) return 'Tối';
                    return m;
                  }
                  return 'Bữa ăn';
                }

                int pA = mealPriority[getMeal(a.name)] ?? 99;
                int pB = mealPriority[getMeal(b.name)] ?? 99;
                return pA.compareTo(pB);
              });

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 48 * scale),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final r = records[index];
                  final List<String> parts = r.name.split(' - ');
                  final String mealType = parts.length > 1 ? parts.last : 'Bữa ăn';
                  final String menuName = parts.isNotEmpty ? parts.first : r.name;
                  
                  final details = menuDetails?[r.menuId];
                  final foods = details?.foods ?? [];

                  // Check if we should show a date header
                  bool showHeader = false;
                  if (index == 0) {
                    showHeader = true;
                  } else {
                    final prevDate = records[index - 1].date;
                    if (prevDate.year != r.date.year || 
                        prevDate.month != r.date.month || 
                        prevDate.day != r.date.day) {
                      showHeader = true;
                    }
                  }

                  return Column(
                    children: [
                      if (showHeader) ...[
                        if (index != 0) SizedBox(height: 24 * scale),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12 * scale),
                          child: Row(
                            children: [
                              Container(
                                width: 4 * scale,
                                height: 18 * scale,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: 10 * scale),
                              Text(
                                fmtDate(r.date),
                                style: AppTextStyles.arimo(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Container(
                        margin: EdgeInsets.only(bottom: 16 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16 * scale),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12 * scale),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16 * scale),
                                        ),
                                        child: Icon(
                                          Icons.restaurant_menu_rounded,
                                          color: AppColors.primary,
                                          size: 22 * scale,
                                        ),
                                      ),
                                      SizedBox(width: 14 * scale),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menuName,
                                              style: AppTextStyles.arimo(
                                                fontSize: 16 * scale,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textPrimary,
                                                height: 1.2,
                                              ),
                                            ),
                                            SizedBox(height: 4 * scale),
                                            Row(
                                              children: [
                                                Text(
                                                  mealType,
                                                  style: AppTextStyles.arimo(
                                                    fontSize: 11 * scale,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                                Text(
                                                  ' • #${r.menuId}',
                                                  style: AppTextStyles.arimo(
                                                    fontSize: 11 * scale,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _iconBtn(icon: Icons.edit_note_rounded, color: AppColors.primary, onPressed: () => onEdit(r), scale: scale),
                                          SizedBox(width: 8 * scale),
                                          _iconBtn(icon: Icons.delete_outline_rounded, color: AppColors.red, onPressed: () => onDelete(r), scale: scale),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (foods.isNotEmpty) ...[
                                    SizedBox(height: 16 * scale),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Combo món ăn (${foods.length} món):',
                                          style: AppTextStyles.arimo(
                                            fontSize: 12 * scale,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (foods.length > 2)
                                          Row(
                                            children: [
                                              Text(
                                                'Kéo xem +${foods.length - 2} món',
                                                style: AppTextStyles.arimo(
                                                  fontSize: 11 * scale,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ).copyWith(fontStyle: FontStyle.italic),
                                              ),
                                              SizedBox(width: 4 * scale),
                                              Icon(Icons.arrow_forward_rounded, size: 14 * scale, color: AppColors.primary),
                                            ],
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 10 * scale),
                                    SizedBox(
                                      height: 85 * scale,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: foods.length,
                                        separatorBuilder: (_, __) => SizedBox(width: 10 * scale),
                                        itemBuilder: (context, fIdx) {
                                          final food = foods[fIdx];
                                          return Container(
                                            width: 160 * scale,
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius: BorderRadius.circular(14 * scale),
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.horizontal(left: Radius.circular(14 * scale)),
                                                  child: Stack(
                                                    children: [
                                                      if (food.imageUrl != null)
                                                        Image.network(
                                                          food.imageUrl!,
                                                          width: 65 * scale,
                                                          height: 85 * scale,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => _noImg(65 * scale),
                                                        )
                                                      else
                                                        _noImg(65 * scale),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                                                    child: Text(
                                                      food.name,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: AppTextStyles.arimo(
                                                        fontSize: 11 * scale,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required Color color, required VoidCallback onPressed, required double scale}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 36 * scale, minHeight: 36 * scale),
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 18 * scale),
      ),
    );
  }

  Widget _noImg(double size) {
    return Container(
      width: size,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported_outlined, size: 20 * scale, color: Colors.grey),
    );
  }
}
