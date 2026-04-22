import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/menu_type_entity.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../../domain/entities/food_entity.dart';
import '../widgets/food_selection_list.dart';

class CreateCustomMenuScreen extends StatefulWidget {
  final MenuTypeEntity menuType;

  const CreateCustomMenuScreen({
    super.key,
    required this.menuType,
  });

  @override
  State<CreateCustomMenuScreen> createState() => _CreateCustomMenuScreenState();
}

class _CreateCustomMenuScreenState extends State<CreateCustomMenuScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final List<int> _selectedFoodIds = [];

  @override
  void initState() {
    super.initState();
    // Load foods when entering the screen
    context.read<MenuBloc>().add(const FoodsLoadRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_nameController.text.isEmpty) {
      AppToast.showWarning(context, message: 'Vui lòng nhập tên thực đơn');
      return;
    }

    if (_selectedFoodIds.isEmpty) {
      AppToast.showWarning(context, message: 'Vui lòng chọn ít nhất một món ăn');
      return;
    }

    final request = {
      'menuTypeId': widget.menuType.id,
      'menuName': _nameController.text,
      'description': _descController.text,
      'foodIds': _selectedFoodIds,
    };

  context.read<MenuBloc>().add(CustomizedMenuCreateRequested(request));
  }

  List<FoodEntity> _getFilteredFoods(List<FoodEntity> allFoods) {
    final typeName = widget.menuType.name.toLowerCase();
    
    return allFoods.where((food) {
      final foodType = food.type.toLowerCase();
      
      // Drink/Tea is allowed for all meals
      if (foodType.contains('drink') || foodType.contains('tea')) {
        return true;
      }
      
      // Determine if food matches meal type
      // Check for snack meals (Phụ) first to avoid overlap with Sáng/Trưa/Chiều names
      if (typeName.contains('phụ')) {
        return foodType.contains('snack');
      }
      
      if (typeName.contains('sáng')) {
        return foodType.contains('breakfast');
      } else if (typeName.contains('trưa')) {
        return foodType.contains('lunch');
      } else if (typeName.contains('chiều') || typeName.contains('tối')) {
        return foodType.contains('dinner');
      }
      
      return true; // Default to show all if unknown menu type
    }).toList();
  }

  Widget _buildSectionHeader(String title, String count, double scale) {
    return Row(
      children: [
        Container(
          width: 4 * scale,
          height: 20 * scale,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2 * scale),
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          title,
          style: AppTextStyles.tinos(
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          count,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.menuCustomTitle,
        centerTitle: true,
      ),
      body: BlocConsumer<MenuBloc, MenuState>(
        listener: (context, state) {
          if (state is MenuError) {
            AppToast.showError(context, message: state.message);
          } else if (state is CustomizedMenuCreateSuccess) {
            AppToast.showSuccess(context, message: 'Tạo thực đơn thành công');
            // Return to previous screen with the newly created menu
            Navigator.of(context).pop(state.newMenu);
          }
        },
        builder: (context, state) {
          if (state is MenuLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is! MenuLoaded) {
            return const SizedBox.shrink();
          }

          // Filter foods by type based on menu type
          final foods = _getFilteredFoods(state.foods);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Menu Type Chip
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                        child: Text(
                          widget.menuType.name,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),

                      // Fields Container
                      Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10 * scale,
                              offset: Offset(0, 4 * scale),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Name Field
                            AppWidgets.textInput(
                              label: AppStrings.menuCustomNameHint,
                              placeholder: 'Ví dụ: Bữa sáng giàu đạm',
                              controller: _nameController,
                            ),
                            SizedBox(height: 20 * scale),
                            // Description Field
                            AppWidgets.textInput(
                              label: AppStrings.menuCustomDescHint,
                              placeholder: 'Thêm mô tả về lựa chọn này...',
                              controller: _descController,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32 * scale),

                      // Food Sections
                      () {
                        final drinkItems = foods.where((f) => f.type.toLowerCase().contains('drink') || f.type.toLowerCase().contains('tea')).toList();
                        final foodItems = foods.where((f) => !f.type.toLowerCase().contains('drink') && !f.type.toLowerCase().contains('tea')).toList();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (foodItems.isNotEmpty) ...[
                              _buildSectionHeader('Món chính & Bữa phụ', '${foodItems.length} món', scale),
                              SizedBox(height: 16 * scale),
                              FoodSelectionList(
                                foods: foodItems,
                                selectedFoodIds: _selectedFoodIds,
                                onSelectionChanged: (ids) {
                                  setState(() {
                                    // We need to merge with existing selected IDs from other categories
                                    final otherCategoryIds = _selectedFoodIds.where((id) => drinkItems.any((f) => f.id == id)).toList();
                                    _selectedFoodIds.clear();
                                    _selectedFoodIds.addAll(ids);
                                    _selectedFoodIds.addAll(otherCategoryIds);
                                  });
                                },
                              ),
                              SizedBox(height: 32 * scale),
                            ],
                            
                            if (drinkItems.isNotEmpty) ...[
                              _buildSectionHeader('Đồ uống', '${drinkItems.length} loại', scale),
                              SizedBox(height: 16 * scale),
                              FoodSelectionList(
                                foods: drinkItems,
                                selectedFoodIds: _selectedFoodIds,
                                onSelectionChanged: (ids) {
                                  setState(() {
                                    final otherCategoryIds = _selectedFoodIds.where((id) => foodItems.any((f) => f.id == id)).toList();
                                    _selectedFoodIds.clear();
                                    _selectedFoodIds.addAll(ids);
                                    _selectedFoodIds.addAll(otherCategoryIds);
                                  });
                                },
                              ),
                            ],
                          ],
                        );
                      }(),
                    ],
                  ),
                ),
              ),

              // Create Button
              Padding(
                padding: EdgeInsets.all(20 * scale),
                child: AppWidgets.primaryButton(
                  text: AppStrings.menuCustomCreate,
                  onPressed: _handleCreate,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
