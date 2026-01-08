import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/family_profile_entity.dart';
import '../../data/models/member_type_model.dart';

/// Family profile form drawer widget
class FamilyProfileFormDrawer extends StatefulWidget {
  final FamilyProfileEntity? member;
  final List<MemberTypeModel> memberTypes;
  final Function({
    required String fullName,
    int? memberTypeId,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? phoneNumber,
    File? avatar,
  }) onSave;

  const FamilyProfileFormDrawer({
    super.key,
    this.member,
    required this.memberTypes,
    required this.onSave,
  });

  @override
  State<FamilyProfileFormDrawer> createState() =>
      _FamilyProfileFormDrawerState();
}

class _FamilyProfileFormDrawerState extends State<FamilyProfileFormDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  int? _selectedMemberTypeId;
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  File? _selectedAvatar;
  String? _avatarUrl;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.member == null;
    if (widget.member != null) {
      _fullNameController.text = widget.member!.fullName;
      _addressController.text = widget.member!.address ?? '';
      _phoneNumberController.text = widget.member!.phoneNumber ?? '';
      final memberTypeId = widget.member!.memberTypeId;
      final hasMemberType = widget.memberTypes
          .any((type) => type.id == memberTypeId && type.isActive);
      _selectedMemberTypeId = hasMemberType ? memberTypeId : null;
      _selectedDateOfBirth = widget.member!.dateOfBirth;
      final gender = widget.member!.gender;
      _selectedGender =
          (gender == 'Nam' || gender == 'Nữ') ? gender : null;
      _avatarUrl = widget.member!.avatarUrl;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<bool> _ensureGalleryPermission() async {
    // Thử photos (Android 13+) trước, nếu không được thì thử storage (Android <13)
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (mounted) {
        AppToast.showWarning(
          context,
          message: AppStrings.pleaseGrantPhotoPermission,
        );
      }
      await openAppSettings();
      return false;
    }

    if (mounted) {
      AppToast.showWarning(
        context,
        message: AppStrings.photoPermissionDenied,
      );
    }
    return false;
  }

  Future<bool> _ensureCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (mounted) {
        AppToast.showWarning(
          context,
          message: AppStrings.pleaseGrantCameraPermission,
        );
      }
      await openAppSettings();
      return false;
    }

    if (mounted) {
      AppToast.showWarning(
        context,
        message: AppStrings.cameraPermissionDenied,
      );
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final granted = source == ImageSource.camera
          ? await _ensureCameraPermission()
          : await _ensureGalleryPermission();
      if (!granted || !mounted) return;

      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      if (image != null && mounted) {
        setState(() {
          _selectedAvatar = File(image.path);
          _avatarUrl = null;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          message: AppStrings.cannotOpenPhotoLibrary.replaceAll('{code}', e.code),
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          message: AppStrings.errorSelectingPhoto.replaceAll('{error}', e.toString()),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    final scale = AppResponsive.scaleFactor(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16 * scale)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text(AppStrings.takePhoto),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text(AppStrings.chooseFromLibrary),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _handleSave() {
    if (!_isEditing) return;
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        fullName: _fullNameController.text.trim(),
        memberTypeId: _selectedMemberTypeId,
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        avatar: _selectedAvatar,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return AppDrawerForm(
      title: widget.member != null
          ? AppStrings.editFamilyMember
          : AppStrings.addFamilyMember,
      onSave: _isEditing ? _handleSave : null,
      saveButtonText: widget.member != null ? AppStrings.save : AppStrings.add,
      children: [
        // Only show view/edit toggle when editing existing member
        if (widget.member != null) ...[
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: (_isEditing ? AppColors.primary : AppColors.textSecondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.edit_rounded : Icons.visibility_rounded,
                      size: 16 * scale,
                      color: _isEditing ? AppColors.primary : AppColors.textSecondary,
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      _isEditing ? AppStrings.editMode : AppStrings.viewMode,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: _isEditing ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(
                  _isEditing ? Icons.visibility_rounded : Icons.edit_rounded,
                  size: 16 * scale,
                ),
                label: Text(
                  _isEditing ? AppStrings.viewMode : AppStrings.edit,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _showImageSourceSheet : null,
                      child: Stack(
                        children: [
                          Container(
                            width: 120 * scale,
                            height: 120 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20 * scale,
                                  offset: Offset(0, 8 * scale),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: EdgeInsets.all(3 * scale),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                              ),
                              child: _selectedAvatar != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _selectedAvatar!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _avatarUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            _avatarUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(
                                              Icons.person_rounded,
                                              size: 60 * scale,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.person_rounded,
                                          size: 60 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.9),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 8 * scale,
                                      offset: Offset(0, 2 * scale),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18 * scale,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: 12 * scale),
                      TextButton.icon(
                        onPressed: _showImageSourceSheet,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * scale,
                            vertical: 8 * scale,
                          ),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                        ),
                        icon: Icon(
                          Icons.image_rounded,
                          size: 18 * scale,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          _selectedAvatar != null || _avatarUrl != null
                              ? AppStrings.changeAvatar
                              : AppStrings.selectAvatar,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24 * scale),

              // Full Name
              AppWidgets.textInput(
                label: AppStrings.profileFullName,
                placeholder: AppStrings.profileFullNamePlaceholder,
                controller: _fullNameController,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.pleaseEnterFullName;
                  }
                  return null;
                },
              ),

              SizedBox(height: 16 * scale),

              // Member Type Radios
              _buildMemberTypeRadios(scale),

              SizedBox(height: 16 * scale),

              // Date of Birth
              _buildDateField(
                label: AppStrings.dateOfBirth,
                value: _selectedDateOfBirth,
                onTap: _isEditing ? () => _selectDate(context) : null,
              ),

              SizedBox(height: 16 * scale),

              // Gender Radios
              _buildGenderRadios(scale),

              SizedBox(height: 16 * scale),

              // Address
              AppWidgets.textInput(
                label: AppStrings.address,
                placeholder: AppStrings.addressPlaceholder,
                controller: _addressController,
                enabled: _isEditing,
              ),

              SizedBox(height: 16 * scale),

              // Phone Number
              AppWidgets.textInput(
                label: AppStrings.phoneNumber,
                placeholder: AppStrings.phoneNumberPlaceholder,
                controller: _phoneNumberController,
                enabled: _isEditing,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return AppStrings.invalidPhoneNumber;
                    }
                  }
                  return null;
                },
              ),

              SizedBox(height: 24 * scale),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTypeRadios(double scale) {
    final items = widget.memberTypes.where((type) => type.isActive).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.memberType,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12 * scale),
        Container(
          padding: EdgeInsets.all(4 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Row(
            children: items
                .map(
                  (type) => Expanded(
                    child: InkWell(
                      onTap: _isEditing
                          ? () => setState(() => _selectedMemberTypeId = type.id)
                          : null,
                      borderRadius: BorderRadius.circular(12 * scale),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12 * scale,
                          horizontal: 8 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedMemberTypeId == type.id
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: _selectedMemberTypeId == type.id
                              ? Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20 * scale,
                              height: 20 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedMemberTypeId == type.id
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  width: 2,
                                ),
                                color: _selectedMemberTypeId == type.id
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                              child: _selectedMemberTypeId == type.id
                                  ? Icon(
                                      Icons.check,
                                      size: 14 * scale,
                                      color: AppColors.white,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 8 * scale),
                            Flexible(
                              child: Text(
                                type.name,
                                style: AppTextStyles.arimo(
                                  fontSize: 14 * scale,
                                  fontWeight: _selectedMemberTypeId == type.id
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _selectedMemberTypeId == type.id
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderRadios(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.gender,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12 * scale),
        Container(
          padding: EdgeInsets.all(4 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _isEditing
                      ? () => setState(() => _selectedGender = 'Nam')
                      : null,
                  borderRadius: BorderRadius.circular(12 * scale),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'Nam'
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: _selectedGender == 'Nam'
                          ? Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20 * scale,
                          height: 20 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedGender == 'Nam'
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                            color: _selectedGender == 'Nam'
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          child: _selectedGender == 'Nam'
                              ? Icon(
                                  Icons.check,
                                  size: 14 * scale,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          AppStrings.male,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: _selectedGender == 'Nam'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: _selectedGender == 'Nam'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: InkWell(
                  onTap: _isEditing
                      ? () => setState(() => _selectedGender = 'Nữ')
                      : null,
                  borderRadius: BorderRadius.circular(12 * scale),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'Nữ'
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: _selectedGender == 'Nữ'
                          ? Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20 * scale,
                          height: 20 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedGender == 'Nữ'
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              width: 2,
                            ),
                            color: _selectedGender == 'Nữ'
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          child: _selectedGender == 'Nữ'
                              ? Icon(
                                  Icons.check,
                                  size: 14 * scale,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          AppStrings.female,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: _selectedGender == 'Nữ'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: _selectedGender == 'Nữ'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback? onTap,
  }) {
    final scale = AppResponsive.scaleFactor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12 * scale),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16 * scale),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 16 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18 * scale,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year}'
                        : AppStrings.selectDate,
                    style: AppTextStyles.arimo(
                      fontSize: 15 * scale,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20 * scale,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
