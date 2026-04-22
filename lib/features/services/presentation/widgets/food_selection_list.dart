import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/food_entity.dart';

class FoodSelectionList extends StatefulWidget {
  final List<FoodEntity> foods;
  final List<int> selectedFoodIds;
  final Function(List<int>) onSelectionChanged;

  const FoodSelectionList({
    super.key,
    required this.foods,
    required this.selectedFoodIds,
    required this.onSelectionChanged,
  });

  @override
  State<FoodSelectionList> createState() => _FoodSelectionListState();
}

class _FoodSelectionListState extends State<FoodSelectionList> {
  late List<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedFoodIds);
  }

  void _toggleSelection(int foodId) {
    setState(() {
      if (_selectedIds.contains(foodId)) {
        _selectedIds.remove(foodId);
      } else {
        _selectedIds.add(foodId);
      }
      widget.onSelectionChanged(_selectedIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (widget.foods.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40 * scale),
          child: Column(
            children: [
              Icon(Icons.restaurant, size: 48 * scale, color: AppColors.textSecondary),
              SizedBox(height: 16 * scale),
              Text(
                'Không có món ăn nào',
                style: AppTextStyles.arimo(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12 * scale,
        mainAxisSpacing: 16 * scale,
        childAspectRatio: 0.65, // Increased height for text
      ),
      itemCount: widget.foods.length,
      itemBuilder: (context, index) {
        final food = widget.foods[index];
        final isSelected = _selectedIds.contains(food.id);

        return GestureDetector(
          onTap: () => _toggleSelection(food.id),
          child: Column(
            children: [
              // Circle Image with Border
              Stack(
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width - 40 * scale - 24 * scale) / 3,
                    height: (MediaQuery.of(context).size.width - 40 * scale - 24 * scale) / 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderLight.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                            ? AppColors.primary.withValues(alpha: 0.15) 
                            : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 4 * scale),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(4 * scale),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: food.imageUrl != null
                          ? AppNetworkImage(
                              food.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.restaurant, 
                                color: AppColors.textSecondary, 
                                size: 24 * scale
                              ),
                            ),
                    ),
                  ),
                  // Selection Indicator
                  if (isSelected)
                    Positioned(
                      top: 4 * scale,
                      right: 4 * scale,
                      child: Container(
                        padding: EdgeInsets.all(4 * scale),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 12 * scale,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8 * scale),
              // Food Name
              Text(
                food.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.tinos(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
