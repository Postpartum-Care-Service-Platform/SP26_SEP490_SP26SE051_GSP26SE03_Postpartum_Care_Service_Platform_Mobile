import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/create_health_record_request.dart';
import '../../domain/entities/health_record_entity.dart';
import '../../domain/repositories/health_record_repository.dart';
import '../bloc/health_record_bloc.dart';
import '../bloc/health_record_event.dart';
import '../bloc/health_record_state.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/avatar_widget.dart';

class CreateHealthRecordSheet extends StatefulWidget {
  final int familyProfileId;
  final bool isBaby;
  final String memberName;
  final String? avatarUrl;
 
   const CreateHealthRecordSheet({
     super.key,
     required this.familyProfileId,
     required this.isBaby,
     required this.memberName,
     this.avatarUrl,
   });

  @override
  State<CreateHealthRecordSheet> createState() => _CreateHealthRecordSheetState();
}

class _CreateHealthRecordSheetState extends State<CreateHealthRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  
  final DateTime _recordDate = DateTime.now();
  final _gestationalAgeController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _generalConditionController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isLoadingConditions = true;
  List<HealthConditionEntity> _conditions = [];
  final List<int> _selectedConditionIds = [];

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    try {
      final allConditions = await InjectionContainer.healthRecordRepository.getHealthConditions();
      if (mounted) {
        setState(() {
          _conditions = allConditions
              .where((c) => c.appliesTo == 'BOTH' || c.appliesTo == (widget.isBaby ? 'BABY' : 'MOM'))
              .toList();
          _isLoadingConditions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingConditions = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _gestationalAgeController.dispose();
    _birthWeightController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _temperatureController.dispose();
    _generalConditionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      final request = CreateHealthRecordRequest(
        familyProfileId: widget.familyProfileId,
        recordDate: _recordDate.toIso8601String(),
        gestationalAgeWeeks: int.tryParse(_gestationalAgeController.text),
        birthWeightGrams: double.tryParse(_birthWeightController.text.replaceAll(',', '.')),
        weight: widget.isBaby ? 0.0 : double.tryParse(_weightController.text.replaceAll(',', '.')),
        height: widget.isBaby ? 0.0 : double.tryParse(_heightController.text.replaceAll(',', '.')),
        temperature: double.tryParse(_temperatureController.text.replaceAll(',', '.')),
        generalCondition: _generalConditionController.text.isNotEmpty ? _generalConditionController.text : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        conditionIds: _selectedConditionIds.isNotEmpty ? _selectedConditionIds : null,
      );

      context.read<HealthRecordBloc>().add(CreateHealthRecord(widget.familyProfileId, request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<HealthRecordBloc, HealthRecordState>(
      listener: (context, state) {
        if (state is CreateHealthRecordSuccess) {
          AppToast.showSuccess(context, message: 'Thêm hồ sơ sức khoẻ thành công');
          Navigator.of(context).pop();
        } else if (state is HealthRecordError) {
          AppToast.showError(context, message: state.message);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        ),
        padding: EdgeInsets.only(
          left: 20 * scale,
          right: 20 * scale,
          top: 24 * scale,
          bottom: bottomInset > 0 ? bottomInset + 20 * scale : 40 * scale,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48 * scale,
                    height: 4 * scale,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2 * scale),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                Text(
                  'Thêm hồ sơ sức khoẻ mới',
                  style: AppTextStyles.tinos(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarWidget(
                      imageUrl: widget.avatarUrl,
                      displayName: widget.memberName,
                      size: 32,
                      fallbackIcon: widget.isBaby ? Icons.child_care_rounded : Icons.pregnant_woman_rounded,
                    ),
                    SizedBox(width: 10 * scale),
                    Text(
                      widget.memberName,
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),

                SizedBox(height: 16 * scale),

                if (widget.isBaby) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppWidgets.textInput(
                          controller: _gestationalAgeController,
                          label: 'Tuần thai',
                          placeholder: 'VD: 39',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: AppWidgets.textInput(
                          controller: _birthWeightController,
                          label: 'Cân lúc sinh (g)',
                          placeholder: 'VD: 3200',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                ],

                if (!widget.isBaby) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppWidgets.textInput(
                          controller: _weightController,
                          label: 'Cân nặng (kg)',
                          placeholder: 'VD: 50',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: AppWidgets.textInput(
                          controller: _heightController,
                          label: 'Chiều cao (cm)',
                          placeholder: 'VD: 160',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                ],

                AppWidgets.textInput(
                  controller: _temperatureController,
                  label: 'Nhiệt độ (°C)',
                  placeholder: 'VD: 37.0',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16 * scale),

                AppWidgets.textInput(
                  controller: _generalConditionController,
                  label: 'Tình trạng chung',
                  placeholder: 'Nhập tình trạng chung...',
                ),
                SizedBox(height: 16 * scale),

                // Conditions multi-select - Categorized & Redesigned
                if (_isLoadingConditions)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ))
                else if (_conditions.isEmpty)
                  Text(
                    'Không có dữ liệu tình trạng',
                    style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
                  )
                else ...[
                  ..._buildCategorizedConditions(scale),
                ],
                SizedBox(height: 8 * scale),

                AppWidgets.textInput(
                  controller: _noteController,
                  label: 'Ghi chú',
                  placeholder: 'Nhập ghi chú thêm...',
                  maxLines: 3,
                ),
                SizedBox(height: 32 * scale),

                BlocBuilder<HealthRecordBloc, HealthRecordState>(
                  builder: (context, state) {
                    final isLoading = state is CreateHealthRecordLoading;
                    return AppWidgets.primaryButton(
                      text: isLoading ? 'Đang lưu...' : 'Lưu hồ sơ',
                      onPressed: isLoading ? () {} : _submit,
                      isEnabled: !isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategorizedConditions(double scale) {
    final Map<String, List<HealthConditionEntity>> categorized = {};
    for (var condition in _conditions) {
      final cat = condition.category ?? 'OTHER';
      categorized.putIfAbsent(cat, () => []).add(condition);
    }

    final List<Widget> widgets = [];
    final categoryLabels = {
      'DELIVERY': 'Hình thức sinh',
      'BABY_STATUS': 'Tình trạng của bé',
      'CHRONIC': 'Bệnh lý mãn tính',
      'ALLERGY': 'Dị ứng',
      'PREFERENCE': 'Ưu tiên / Sở thích',
      'OTHER': 'Khác',
    };

    final categoryIcons = {
      'DELIVERY': Icons.pregnant_woman_rounded,
      'BABY_STATUS': Icons.child_care_rounded,
      'CHRONIC': Icons.medical_services_outlined,
      'ALLERGY': Icons.science_outlined,
      'PREFERENCE': Icons.favorite_border_rounded,
      'OTHER': Icons.info_outline_rounded,
    };

    // Define preferred order
    final order = ['DELIVERY', 'BABY_STATUS', 'CHRONIC', 'ALLERGY', 'PREFERENCE', 'OTHER'];
    
    for (final catKey in order) {
      if (categorized.containsKey(catKey)) {
        final conditions = categorized[catKey]!;
        widgets.add(Padding(
          padding: EdgeInsets.only(top: 16 * scale, bottom: 8 * scale),
          child: Row(
            children: [
              Icon(categoryIcons[catKey] ?? Icons.info_outline, size: 16 * scale, color: AppColors.textSecondary),
              SizedBox(width: 8 * scale),
              Text(
                categoryLabels[catKey] ?? catKey,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ));

        widgets.add(
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: conditions.map((condition) {
              final isSelected = _selectedConditionIds.contains(condition.id);
              return _buildConditionItem(scale, condition, isSelected);
            }).toList(),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildConditionItem(double scale, HealthConditionEntity condition, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedConditionIds.remove(condition.id);
          } else {
            _selectedConditionIds.add(condition.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ] : null,
        ),
        child: Text(
          condition.name,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
