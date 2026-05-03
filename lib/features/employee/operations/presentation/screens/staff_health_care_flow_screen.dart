import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/health_record/domain/entities/health_record_entity.dart';
import '../../../../../features/health_record/presentation/bloc/health_record_bloc.dart';
import '../../../../../features/health_record/presentation/bloc/health_record_event.dart';
import '../../../../../features/health_record/presentation/bloc/health_record_state.dart';
import '../../../../../features/health_record/data/models/create_health_record_request.dart';
import '../../../../../core/widgets/app_toast.dart';

class StaffHealthCareFlowScreen extends StatefulWidget {
  final int familyProfileId;
  final String familyMemberName;
  final String? memberType;
  final int? activityId;
  final String? activityName;
  final bool isBottomSheet;

  const StaffHealthCareFlowScreen({
    super.key,
    required this.familyProfileId,
    required this.familyMemberName,
    this.memberType,
    this.activityId,
    this.activityName,
    this.isBottomSheet = false,
  });

  static Future<void> showAsBottomSheet(
    BuildContext context, {
    required int familyProfileId,
    required String familyMemberName,
    String? memberType,
    int? activityId,
    String? activityName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => StaffHealthCareFlowScreen(
        familyProfileId: familyProfileId,
        familyMemberName: familyMemberName,
        memberType: memberType,
        activityId: activityId,
        activityName: activityName,
        isBottomSheet: true,
      ),
    );
  }

  @override
  State<StaffHealthCareFlowScreen> createState() => _StaffHealthCareFlowScreenState();
}

class _StaffHealthCareFlowScreenState extends State<StaffHealthCareFlowScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _tempController = TextEditingController();
  final _gestationalAgeController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _conditionController = TextEditingController();
  final _noteController = TextEditingController();
  List<int> _selectedConditionIds = [];
  List<HealthConditionEntity> _allConditions = [];

  bool get isBaby {
    final type = widget.memberType?.toLowerCase() ?? '';
    return type.contains('baby') || type.contains('bé') || type.contains('trẻ');
  }

  bool get isMom {
    final type = widget.memberType?.toLowerCase() ?? '';
    return type.contains('mom') || type.contains('mẹ') || type.contains('sản phụ');
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('DEBUG: StaffHealthCareFlowScreen initState - familyProfileId: ${widget.familyProfileId}');
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _tempController.dispose();
    _gestationalAgeController.dispose();
    _birthWeightController.dispose();
    _conditionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    final content = BlocProvider(
      create: (context) {
        final bloc = InjectionContainer.healthRecordBloc;
        bloc.add(GetLatestHealthRecord(widget.familyProfileId));
        bloc.add(GetHealthConditions(memberTypeId: isBaby ? 3 : 2));
        return bloc;
      },
      child: BlocConsumer<HealthRecordBloc, HealthRecordState>(
        listener: (context, state) {
          if (state is HealthConditionsLoaded) {
            _allConditions = state.conditions;
          } else if (state is HealthRecordLatestLoaded) {
            _weightController.text = state.record.weight?.toString() ?? '';
            _heightController.text = state.record.height?.toString() ?? '';
            _tempController.text = state.record.temperature?.toString() ?? '';
            _gestationalAgeController.text = state.record.gestationalAgeWeeks?.toString() ?? '';
            _birthWeightController.text = state.record.birthWeightGrams?.toString() ?? '';
            _conditionController.text = state.record.generalCondition ?? '';
            _noteController.text = state.record.note ?? '';
            _selectedConditionIds = state.record.conditions.map((e) => e.id).toList();
          } else if (state is CreateHealthRecordSuccess) {
            AppToast.showSuccess(context, message: 'Đã lưu ghi chú sức khỏe');
            Navigator.pop(context);
          } else if (state is HealthRecordNotFound) {
            // Ignore
          } else if (state is HealthRecordError) {
            AppToast.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is HealthRecordLoading && _allConditions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return Stack(
            children: [
              // Top Gradient Background (only for Screen mode)
              if (!widget.isBottomSheet)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 300 * scale,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              
              // Content
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    if (widget.isBottomSheet) _buildBottomSheetHandle(scale),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20 * scale, widget.isBottomSheet ? 0 : 10 * scale, 20 * scale, 120 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.isBottomSheet) ...[
                              SizedBox(height: 10 * scale),
                              Center(
                                child: Text(
                                  'Ghi nhận sức khỏe',
                                  style: AppTextStyles.arimo(
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20 * scale),
                            ],
                            _buildProfileHeader(scale),
                            SizedBox(height: 24 * scale),
                            
                            _buildSectionHeader('Chỉ số sức khoẻ', Icons.favorite_rounded, scale),
                            SizedBox(height: 16 * scale),
                            _buildVitalSignsGrid(scale),
                            
                            if (isBaby) ...[
                              SizedBox(height: 24 * scale),
                              _buildSectionHeader('Thông tin phát triển', Icons.child_friendly_rounded, scale),
                              SizedBox(height: 16 * scale),
                              _buildDevelopmentSection(scale),
                            ],
                            
                            SizedBox(height: 24 * scale),
                            _buildSectionHeader('Đánh giá tổng quát', Icons.assignment_rounded, scale),
                            SizedBox(height: 16 * scale),
                            _buildGeneralObservationSection(scale),
                            
                            SizedBox(height: 24 * scale),
                            _buildSectionHeader('Tình trạng & Yêu cầu', Icons.medical_information_rounded, scale),
                            SizedBox(height: 8 * scale),
                            _buildConditionSection(scale),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomActions(context, scale),
              ),
            ],
          );
        },
      ),
    );

    if (widget.isBottomSheet) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32 * scale)),
        ),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(scale),
      body: content,
    );
  }

  Widget _buildBottomSheetHandle(double scale) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12 * scale),
      width: 40 * scale,
      height: 4 * scale,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double scale) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Ghi nhận sức khỏe',
        style: AppTextStyles.arimo(
          fontWeight: FontWeight.w900,
          fontSize: 18 * scale,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProfileHeader(double scale) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3 * scale),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 30 * scale,
              backgroundColor: AppColors.background,
              child: Icon(
                isBaby ? Icons.child_care_rounded : Icons.person_rounded,
                color: AppColors.primary,
                size: 32 * scale,
              ),
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.familyMemberName,
                  style: AppTextStyles.arimo(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: (isBaby ? Colors.pink : AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  child: Text(
                    isBaby ? 'Bé sơ sinh' : 'Người mẹ',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w800,
                      color: isBaby ? Colors.pink[700] : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.activityName != null)
            _buildActivityBadge(scale),
        ],
      ),
    );
  }

  Widget _buildActivityBadge(double scale) {
    return Container(
      width: 44 * scale,
      height: 44 * scale,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.info_outline_rounded, color: Colors.orange[800], size: 20 * scale),
        onPressed: () {
           AppToast.showInfo(context, message: 'Công việc: ${widget.activityName}');
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, double scale) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20 * scale),
        SizedBox(width: 8 * scale),
        Text(
          title,
          style: AppTextStyles.arimo(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalSignsGrid(double scale) {
    return Row(
      children: [
        Expanded(
          child: _buildVitalCard(
            controller: _weightController,
            label: 'Cân nặng',
            unit: 'kg',
            icon: Icons.monitor_weight_outlined,
            color: Colors.blue,
            scale: scale,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _buildVitalCard(
            controller: _tempController,
            label: 'Nhiệt độ',
            unit: '°C',
            icon: Icons.thermostat_rounded,
            color: Colors.orange,
            scale: scale,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _buildVitalCard(
            controller: _heightController,
            label: 'Chiều cao',
            unit: 'cm',
            icon: Icons.height_rounded,
            color: Colors.green,
            scale: scale,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required Color color,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20 * scale),
          SizedBox(height: 8 * scale),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.arimo(
              fontWeight: FontWeight.w900,
              fontSize: 18 * scale,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '0.0',
              hintStyle: AppTextStyles.arimo(color: Colors.grey[300], fontSize: 18 * scale),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            '$label ($unit)',
            style: AppTextStyles.arimo(
              fontSize: 10 * scale,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentSection(double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModernField(
              controller: _gestationalAgeController,
              label: 'Tuổi thai',
              unit: 'tuần',
              icon: Icons.child_care_rounded,
              scale: scale,
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: _buildModernField(
              controller: _birthWeightController,
              label: 'Cân nặng sinh',
              unit: 'g',
              icon: Icons.scale_rounded,
              scale: scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralObservationSection(double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModernTextField(
            controller: _conditionController,
            label: 'Tình trạng chung',
            hint: 'Chưa có thông tin',
            icon: Icons.health_and_safety_outlined,
            scale: scale,
            readOnly: true,
          ),
          SizedBox(height: 16 * scale),
          _buildModernTextField(
            controller: _noteController,
            label: 'Ghi chú bổ sung',
            hint: 'Nhập ghi chú chi tiết...',
            icon: Icons.note_add_outlined,
            maxLines: 3,
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14 * scale, color: Colors.pink),
            SizedBox(width: 6 * scale),
            Text(label, style: AppTextStyles.arimo(fontSize: 12 * scale, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.arimo(fontWeight: FontWeight.w800, fontSize: 16 * scale),
          decoration: InputDecoration(
            isDense: true,
            suffixText: unit,
            suffixStyle: AppTextStyles.arimo(fontSize: 12 * scale, color: Colors.grey),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderLight)),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required double scale,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20 * scale),
        labelStyle: AppTextStyles.arimo(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildConditionSection(double scale) {
    if (_allConditions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            'Đang tải danh sách...',
            style: AppTextStyles.arimo(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Use all conditions since Bloc already filters by memberTypeId
    final filtered = _allConditions;

    // Grouping logic (Case-insensitive)
    final Map<String, List<HealthConditionEntity>> categorized = {};
    for (var condition in filtered) {
      final cat = condition.category.toUpperCase();
      categorized.putIfAbsent(cat, () => []).add(condition);
    }

    final categoryLabels = {
      'DELIVERY': 'Hình thức sinh',
      'BABY_STATUS': 'Tình trạng của bé',
      'CHRONIC': 'Bệnh lý mãn tính',
      'ALLERGY': 'Dị ứng',
      'PREFERENCE': 'Yêu cầu / Sở thích',
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

    final order = ['DELIVERY', 'BABY_STATUS', 'CHRONIC', 'ALLERGY', 'PREFERENCE', 'OTHER'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "None" or "Normal" Chip
        InkWell(
          onTap: () {
            setState(() {
              _selectedConditionIds.clear();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              color: _selectedConditionIds.isEmpty ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: _selectedConditionIds.isEmpty ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
              ),
              boxShadow: _selectedConditionIds.isEmpty
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Text(
              'Bình thường / Không có',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                fontWeight: _selectedConditionIds.isEmpty ? FontWeight.w900 : FontWeight.w600,
                color: _selectedConditionIds.isEmpty ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        
        ...order.map((catKey) {
          if (!categorized.containsKey(catKey)) return const SizedBox.shrink();
          
          final conditions = categorized[catKey]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20 * scale, bottom: 10 * scale),
                child: Row(
                  children: [
                    Icon(categoryIcons[catKey] ?? Icons.info_outline, size: 16 * scale, color: AppColors.primary),
                    SizedBox(width: 8 * scale),
                    Text(
                      categoryLabels[catKey] ?? catKey,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 10 * scale,
                runSpacing: 10 * scale,
                children: conditions.map((condition) {
                  final isSelected = _selectedConditionIds.contains(condition.id);
                  return InkWell(
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
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        condition.name,
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, double scale) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, widget.isBottomSheet ? 10 * scale : 30 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isBottomSheet ? null : BorderRadius.vertical(top: Radius.circular(32 * scale)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 56 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18 * scale),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF9A8B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _submitForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
          ),
          child: Text(
            'Xác nhận lưu hồ sơ',
            style: AppTextStyles.arimo(
              fontWeight: FontWeight.w900,
              fontSize: 16 * scale,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    // 1. Get raw values
    final weightStr = _weightController.text.trim().replaceAll(',', '.');
    final heightStr = _heightController.text.trim().replaceAll(',', '.');
    final tempStr = _tempController.text.trim().replaceAll(',', '.');
    final gestationalAgeStr = _gestationalAgeController.text.trim();
    final birthWeightStr = _birthWeightController.text.trim();

    // 2. Data Type Validation (Check if not empty but invalid)
    if (weightStr.isNotEmpty && double.tryParse(weightStr) == null) {
      AppToast.showError(context, message: 'Cân nặng phải là số (VD: 55.5)');
      return;
    }
    if (heightStr.isNotEmpty && double.tryParse(heightStr) == null) {
      AppToast.showError(context, message: 'Chiều cao phải là số (VD: 165)');
      return;
    }
    if (tempStr.isNotEmpty && double.tryParse(tempStr) == null) {
      AppToast.showError(context, message: 'Nhiệt độ phải là số (VD: 36.5)');
      return;
    }
    if (gestationalAgeStr.isNotEmpty && int.tryParse(gestationalAgeStr) == null) {
      AppToast.showError(context, message: 'Tuổi thai phải là số nguyên');
      return;
    }
    if (birthWeightStr.isNotEmpty && int.tryParse(birthWeightStr) == null) {
      AppToast.showError(context, message: 'Cân nặng lúc sinh phải là số nguyên (gram)');
      return;
    }

    // 3. Parse values
    final weight = double.tryParse(weightStr);
    final height = double.tryParse(heightStr);
    final temp = double.tryParse(tempStr);
    final gestationalAge = int.tryParse(gestationalAgeStr);
    final birthWeight = int.tryParse(birthWeightStr);

    // 4. Logical Range Validation
    if (weight != null) {
      if (isBaby) {
        if (weight <= 0) {
          AppToast.showError(context, message: 'Cân nặng của bé phải lớn hơn 0');
          return;
        }
        if (weight > 20) {
          AppToast.showError(context, message: 'Cân nặng của bé không thể vượt quá 20kg');
          return;
        }
      } else {
        if (weight < 30) {
          AppToast.showError(context, message: 'Cân nặng của mẹ phải từ 30kg trở lên');
          return;
        }
        if (weight > 250) {
          AppToast.showError(context, message: 'Cân nặng vượt quá giới hạn cho phép (250kg)');
          return;
        }
      }
    }

    if (temp != null && (temp < 30 || temp > 45)) {
      AppToast.showError(context, message: 'Nhiệt độ không hợp lệ (30°C - 45°C)');
      return;
    }

    if (height != null) {
      if (isBaby) {
        if (height < 40 || height > 120) {
          AppToast.showError(context, message: 'Chiều cao bé không hợp lệ (40cm - 120cm)');
          return;
        }
      } else {
        if (height < 100 || height > 250) {
          AppToast.showError(context, message: 'Chiều cao mẹ không hợp lệ (100cm - 250cm)');
          return;
        }
      }
    }

    final request = CreateHealthRecordRequest(
      familyProfileId: widget.familyProfileId,
      recordDate: DateTime.now().toIso8601String(),
      weight: weight,
      height: height,
      temperature: temp,
      gestationalAgeWeeks: gestationalAge,
      birthWeightGrams: birthWeight,
      generalCondition: _conditionController.text.trim(),
      note: _noteController.text.trim(),
      conditionIds: _selectedConditionIds,
    );

    context.read<HealthRecordBloc>().add(CreateHealthRecord(widget.familyProfileId, request));
  }
}
