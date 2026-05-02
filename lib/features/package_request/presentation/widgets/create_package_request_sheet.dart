import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../package/presentation/widgets/package_card.dart';
import '../../data/models/create_package_request_model.dart';
import '../bloc/package_request_bloc.dart';
import '../bloc/package_request_event.dart';
import '../bloc/package_request_state.dart';

class CreatePackageRequestSheet extends StatefulWidget {
  const CreatePackageRequestSheet({super.key});

  @override
  State<CreatePackageRequestSheet> createState() =>
      _CreatePackageRequestSheetState();
}

class _CreatePackageRequestSheetState extends State<CreatePackageRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();


  int _totalDays = 7;
  PackageEntity? _selectedPackage;
  List<PackageEntity> _packages = [];
  bool _isLoadingPackages = true;

  List<FamilyProfileEntity> _familyProfiles = [];
  bool _isLoadingProfiles = true;
  final List<int> _selectedProfileIds = [];
  final Map<int, bool> _hasHealthRecordMap = {};

  @override
  void initState() {
    super.initState();
    _loadPackages();
    _loadFamilyProfiles();
  }

  Future<void> _loadPackages() async {
    try {
      final packages =
          await InjectionContainer.packageRepository.getPackages();
      if (mounted) {
        setState(() {
          // Chỉ hiển thị gói đang hoạt động
          _packages = packages.where((p) => p.isActive).toList();
          _isLoadingPackages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPackages = false);
      }
    }
  }

  Future<void> _loadFamilyProfiles() async {
    try {
      final profiles =
          await InjectionContainer.familyProfileRepository
              .getMyFamilyProfiles();
      
      final Map<int, bool> healthRecordMap = {};
      for (final profile in profiles) {
        try {
          final records = await InjectionContainer.healthRecordRepository
              .getHealthRecordsByFamilyProfile(profile.id);
          healthRecordMap[profile.id] = records.isNotEmpty;
        } catch (_) {
          healthRecordMap[profile.id] = false;
        }
      }

      if (mounted) {
        setState(() {
          // Chỉ hiển thị Mẹ và Bé
          _familyProfiles = profiles
              .where((p) =>
                  p.memberTypeName?.toLowerCase() == 'mom' ||
                  p.memberTypeName?.toLowerCase() == 'baby')
              .toList();
          _hasHealthRecordMap.addAll(healthRecordMap);
          _isLoadingProfiles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfiles = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }



  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPackage == null) {
        AppToast.showError(context, message: 'Vui lòng chọn gói mẫu');
        return;
      }
      final hasMom = _familyProfiles.any((p) => 
          _selectedProfileIds.contains(p.id) && 
          p.memberTypeName?.toLowerCase() == 'mom');
      final hasBaby = _familyProfiles.any((p) => 
          _selectedProfileIds.contains(p.id) && 
          p.memberTypeName?.toLowerCase() == 'baby');

      if (!hasMom || !hasBaby) {
        AppToast.showError(context,
            message: 'Vui lòng chọn cả hồ sơ Mẹ và Bé');
        return;
      }

      FocusScope.of(context).unfocus();

      final request = CreatePackageRequestModel(
        basePackageId: _selectedPackage!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requestedStartDate:
            DateTime.now().toIso8601String().split('T').first,
        totalDays: _totalDays,
        familyProfileIds: _selectedProfileIds,
      );

      context
          .read<PackageRequestBloc>()
          .add(CreatePackageRequestEvent(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<PackageRequestBloc, PackageRequestState>(
      listener: (context, state) {
        if (state is PackageRequestCreated) {
          AppToast.showSuccess(context,
              message: 'Tạo yêu cầu cá nhân hoá thành công');
          Navigator.of(context).pop();
        } else if (state is PackageRequestError) {
          AppToast.showError(context, message: 'Đã xảy ra lỗi');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24 * scale)),
        ),
        padding: EdgeInsets.only(
          left: 20 * scale,
          right: 20 * scale,
          top: 16 * scale,
          bottom: bottomInset > 0 ? bottomInset + 20 * scale : 40 * scale,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
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
                SizedBox(height: 20 * scale),

                // Title
                Text(
                  'Tạo yêu cầu cá nhân hoá gói',
                  style: AppTextStyles.tinos(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Chọn gói mẫu và thành viên gia đình để trung tâm\ntùy chỉnh gói dịch vụ phù hợp nhất.',
                  style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24 * scale),

                // ---- Section: Chọn gói mẫu ----
                _buildSectionLabel(scale, 'Chọn gói mẫu',
                    Icons.inventory_2_outlined),
                SizedBox(height: 8 * scale),
                if (_isLoadingPackages)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()))
                else if (_selectedPackage != null)
                  // Hiển thị gói đã chọn
                  GestureDetector(
                    onTap: () => _showPackagePickerDrawer(scale),
                    child: Stack(
                      children: [
                        PackageCard(
                          package: _selectedPackage!,
                          onTap: () => _showPackagePickerDrawer(scale),
                          aspectRatio: 4 / 3,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            margin: EdgeInsets.all(8 * scale),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10 * scale, vertical: 5 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_horiz_rounded,
                                    size: 14 * scale, color: AppColors.white),
                                SizedBox(width: 4 * scale),
                                Text(
                                  'Đổi gói',
                                  style: AppTextStyles.arimo(
                                    fontSize: 11 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Placeholder khi chưa chọn gói
                  GestureDetector(
                    onTap: () => _showPackagePickerDrawer(scale),
                    child: Container(
                      height: 120 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(
                          color: AppColors.borderLight,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline_rounded,
                                size: 36 * scale, color: AppColors.primary),
                            SizedBox(height: 8 * scale),
                            Text(
                              'Bấm để chọn gói dịch vụ',
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20 * scale),

                // ---- Title ----
                AppWidgets.textInput(
                  controller: _titleController,
                  label: 'Tiêu đề yêu cầu',
                  placeholder: 'VD: Cá nhân hóa cho vợ và bé',
                ),
                SizedBox(height: 16 * scale),

                // ---- Description ----
                AppWidgets.textInput(
                  controller: _descriptionController,
                  label: 'Mô tả chi tiết',
                  placeholder:
                      'Mô tả nhu cầu cá nhân hoá của bạn...',
                  maxLines: 3,
                ),
                SizedBox(height: 20 * scale),

                // ---- Section: Chọn thành viên gia đình ----
                _buildSectionLabel(scale, 'Chọn đối tượng phục vụ',
                    Icons.family_restroom_rounded),
                SizedBox(height: 8 * scale),
                if (_isLoadingProfiles)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()))
                else if (_familyProfiles.isEmpty)
                  Text(
                    'Chưa có thành viên nào trong hồ sơ gia đình',
                    style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        color: AppColors.textSecondary),
                  )
                else
                  ..._familyProfiles.map((profile) {
                    final isSelected =
                        _selectedProfileIds.contains(profile.id);
                    final hasHealthRecord = _hasHealthRecordMap[profile.id] ?? false;
                    
                    return GestureDetector(
                      onTap: () {
                        if (!hasHealthRecord) {
                          AppToast.showError(
                            context,
                            message: 'Vui lòng cập nhật hồ sơ sức khỏe cho ${profile.fullName} trước khi chọn (Ấn giữ vào thẻ tại trang hồ sơ gia đình)',
                            duration: const Duration(seconds: 4),
                          );
                          return;
                        }
                        setState(() {
                          if (isSelected) {
                            _selectedProfileIds.remove(profile.id);
                          } else {
                            _selectedProfileIds.add(profile.id);
                          }
                        });
                      },
                      child: Opacity(
                        opacity: !hasHealthRecord ? 0.6 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 8 * scale),
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            color: !hasHealthRecord
                                ? AppColors.background
                                : isSelected
                                    ? AppColors.primary.withValues(alpha: 0.06)
                                    : AppColors.white,
                            borderRadius:
                                BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Checkbox
                              Container(
                                width: 22 * scale,
                                height: 22 * scale,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(Icons.check,
                                        size: 14 * scale,
                                        color: AppColors.white)
                                    : null,
                              ),
                              SizedBox(width: 12 * scale),
                              // Avatar
                              AvatarWidget(
                                imageUrl: profile.avatarUrl,
                                displayName: profile.fullName,
                                size: 40,
                                fallbackIcon: profile.memberTypeName?.toLowerCase() == 'mom'
                                    ? Icons.pregnant_woman_rounded
                                    : Icons.child_care_rounded,
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.fullName,
                                      style: AppTextStyles.arimo(
                                        fontSize: 15 * scale,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2 * scale),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8 * scale,
                                            vertical: 2 * scale,
                                          ),
                                          decoration: BoxDecoration(
                                            color: profile.memberTypeName?.toLowerCase() == 'mom'
                                                ? AppColors.primary.withValues(alpha: 0.1)
                                                : const Color(0xFF1565C0).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10 * scale),
                                          ),
                                          child: Text(
                                            profile.memberTypeName?.toLowerCase() == 'mom'
                                                ? 'Mẹ'
                                                : 'Bé',
                                            style: AppTextStyles.arimo(
                                              fontSize: 11 * scale,
                                              fontWeight: FontWeight.w600,
                                              color: profile.memberTypeName?.toLowerCase() == 'mom'
                                                  ? AppColors.primary
                                                  : const Color(0xFF1565C0),
                                            ),
                                          ),
                                        ),
                                        if (!hasHealthRecord) ...[
                                          SizedBox(width: 8 * scale),
                                          Text(
                                            '⚠️ Thiếu hồ sơ sức khỏe',
                                            style: AppTextStyles.arimo(
                                              fontSize: 11 * scale,
                                              color: const Color(0xFFF44336),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                SizedBox(height: 24 * scale),

                // ---- Submit button ----
                BlocBuilder<PackageRequestBloc, PackageRequestState>(
                  builder: (context, state) {
                    final isLoading =
                        state is PackageRequestActionLoading;
                    final hasMom = _familyProfiles.any((p) => 
                        _selectedProfileIds.contains(p.id) && 
                        p.memberTypeName?.toLowerCase() == 'mom');
                    final hasBaby = _familyProfiles.any((p) => 
                        _selectedProfileIds.contains(p.id) && 
                        p.memberTypeName?.toLowerCase() == 'baby');
                    final canSubmit = !isLoading && hasMom && hasBaby;
                    
                    return AppWidgets.primaryButton(
                      text: isLoading
                          ? 'Đang gửi...'
                          : 'Gửi yêu cầu cá nhân hoá',
                      icon: isLoading 
                          ? null 
                          : Icon(Icons.auto_awesome, size: 20 * scale, color: AppColors.white),
                      onPressed: canSubmit ? _submit : () {},
                      isEnabled: canSubmit,
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

  void _showPackagePickerDrawer(double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            SizedBox(height: 12 * scale),
            Container(
              width: 48 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Chọn gói dịch vụ',
              style: AppTextStyles.tinos(
                fontSize: 20 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              '${_packages.length} gói đang hoạt động',
              style: AppTextStyles.arimo(
                  fontSize: 13 * scale, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16 * scale),
            // Package list
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 8 * scale),
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final pkg = _packages[index];
                  final isSelected = _selectedPackage?.id == pkg.id;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12 * scale),
                    child: Stack(
                      children: [
                        PackageCard(
                          package: pkg,
                          aspectRatio: 4 / 3,
                          onTap: () {
                            setState(() {
                              _selectedPackage = pkg;
                              if (pkg.durationDays != null) {
                                _totalDays = pkg.durationDays!;
                              }
                            });
                            Navigator.pop(ctx);
                          },
                        ),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(16 * scale),
                                border: Border.all(
                                    color: AppColors.primary, width: 3),
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: EdgeInsets.all(8 * scale),
                                  padding: EdgeInsets.all(3 * scale),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check_rounded,
                                      size: 16 * scale,
                                      color: AppColors.white),
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
            SizedBox(height: 16 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
      double scale, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16 * scale, color: AppColors.textSecondary),
        SizedBox(width: 8 * scale),
        Text(
          title,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
