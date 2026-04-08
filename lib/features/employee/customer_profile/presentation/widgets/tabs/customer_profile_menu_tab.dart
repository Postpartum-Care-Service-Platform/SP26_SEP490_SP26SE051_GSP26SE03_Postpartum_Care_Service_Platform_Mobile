import 'package:flutter/material.dart';

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

  const CustomerProfileMenuTab({
    super.key,
    required this.future,
    required this.scale,
    required this.fmtDate,
    required this.filterWidget,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
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
                    'Không tải được Thực đơn khách hàng:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
                  ),
                );
              }
              final records = snapshot.data ?? const [];
              if (records.isEmpty) {
                return Center(
                  child: Text(
                    'Không có Thực đơn khách hàng theo bộ lọc hiện tại.',
                    style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
                  ),
                );
              }

              records.sort((a, b) => b.date.compareTo(a.date));

              return ListView.separated(
                padding: EdgeInsets.all(16 * scale),
                itemCount: records.length,
                separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                itemBuilder: (context, index) {
                  final r = records[index];
                  final List<String> parts = r.name.split(' - ');
                  final String mealType = parts.length > 1 ? parts.last : 'Bữa ăn';
                  final String menuName = parts.isNotEmpty ? parts.first : r.name;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20 * scale),
                      border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20 * scale),
                      child: InkWell(
                        onTap: () => onViewDetails(r.menuId),
                        borderRadius: BorderRadius.circular(20 * scale),
                        child: Padding(
                          padding: EdgeInsets.all(16 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10 * scale),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF97316).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: const Color(0xFFF97316),
                                      size: 20 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menuName,
                                          style: AppTextStyles.arimo(
                                            fontSize: 15 * scale,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            height: 1.3,
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Row(
                                          children: [
                                            Icon(Icons.wb_sunny_outlined, size: 12 * scale, color: const Color(0xFFF97316)),
                                            SizedBox(width: 4 * scale),
                                            Text(
                                              mealType,
                                              style: AppTextStyles.arimo(
                                                fontSize: 12 * scale,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFF97316),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Sửa',
                                        onPressed: () => onEdit(r),
                                        icon: Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 20 * scale),
                                      ),
                                      SizedBox(width: 12 * scale),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Xóa',
                                        onPressed: () => onDelete(r),
                                        icon: Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20 * scale),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16 * scale),
                              Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12 * scale),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, size: 16 * scale, color: AppColors.textSecondary),
                                    SizedBox(width: 8 * scale),
                                    Text(
                                      'Ngày áp dụng',
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      fmtDate(r.date),
                                      style: AppTextStyles.arimo(
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
