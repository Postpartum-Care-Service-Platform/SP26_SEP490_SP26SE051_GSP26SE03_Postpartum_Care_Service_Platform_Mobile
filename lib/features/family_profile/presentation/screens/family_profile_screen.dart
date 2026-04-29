import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/services/current_account_cache_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/family_profile_entity.dart';
import '../../data/models/create_family_profile_request_model.dart';
import '../../data/models/update_family_profile_request_model.dart';
import '../../data/models/member_type_model.dart';
import '../bloc/family_profile_bloc.dart';
import '../widgets/family_member_card.dart';
import '../widgets/family_profile_form_drawer.dart';
import '../../../health_record/presentation/screens/health_record_screen.dart';
import '../../../health_record/presentation/bloc/health_record_bloc.dart';
import '../../../../core/di/injection_container.dart';

class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyProfileBloc>().add(const FamilyProfileStarted());
  }

  void _showAddMemberDrawer() {
    final bloc = context.read<FamilyProfileBloc>();
    final memberTypes = bloc.state.memberTypes;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FamilyProfileFormDrawer(
        member: null,
        memberTypes: memberTypes,
        onSave: ({
          required String fullName,
          int? memberTypeId,
          DateTime? dateOfBirth,
          String? gender,
          String? address,
          String? phoneNumber,
          File? avatar,
        }) => _handleSave(
          null,
          fullName: fullName,
          memberTypeId: memberTypeId,
          dateOfBirth: dateOfBirth,
          gender: gender,
          address: address,
          phoneNumber: phoneNumber,
          avatar: avatar,
        ),
      ),
    );
  }

  void _showEditMemberDrawer(FamilyProfileEntity member) {
    final bloc = context.read<FamilyProfileBloc>();
    final memberTypes = bloc.state.memberTypes;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FamilyProfileFormDrawer(
        member: member,
        memberTypes: memberTypes,
        onSave: ({
          required String fullName,
          int? memberTypeId,
          DateTime? dateOfBirth,
          String? gender,
          String? address,
          String? phoneNumber,
          File? avatar,
        }) => _handleSave(
          member.id,
          fullName: fullName,
          memberTypeId: memberTypeId,
          dateOfBirth: dateOfBirth,
          gender: gender,
          address: address,
          phoneNumber: phoneNumber,
          avatar: avatar,
        ),
      ),
    );
  }

  Future<void> _handleSave(
    int? memberId, {
    required String fullName,
    int? memberTypeId,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? phoneNumber,
    File? avatar,
  }) async {
    if (memberId == null) {
      // Create new member
      AppLoading.show(context, message: AppStrings.processing);
      try {
        final request = CreateFamilyProfileRequestModel(
          memberTypeId: memberTypeId,
          fullName: fullName,
          dateOfBirth: dateOfBirth,
          gender: gender,
          address: address,
          phoneNumber: phoneNumber,
          avatar: avatar,
        );

        await context.read<FamilyProfileBloc>().createFamilyProfileUsecase(request);

        if (mounted) {
          AppLoading.hide(context);
          Navigator.of(context).pop();
          AppToast.showSuccess(context, message: AppStrings.updateSuccess);
          context.read<FamilyProfileBloc>().add(const FamilyProfileRefreshed());
        }
      } catch (e) {
        if (mounted) {
          AppLoading.hide(context);
          AppToast.showError(context, message: '${AppStrings.updateFailed}: $e');
        }
      }
      return;
    }

    // Update existing member
    AppLoading.show(context, message: AppStrings.updating);
    try {
      // Check if member being updated is the owner (isOwner = true)
      // Get member info before update to check isOwner status
      final blocState = context.read<FamilyProfileBloc>().state;
      final memberToUpdate = blocState.members.firstWhere(
        (member) => member.id == memberId,
        orElse: () => blocState.members.first,
      );
      final isOwnerUpdate = memberToUpdate.isOwner;

      final request = UpdateFamilyProfileRequestModel(
        memberTypeId: memberTypeId,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        phoneNumber: phoneNumber,
        avatar: avatar,
      );

      // Tạm thời vẫn gọi repository trực tiếp thông qua bloc's repository pattern
      // (update usecase/bloc có thể thêm sau nếu cần mở rộng).
      await context
          .read<FamilyProfileBloc>()
          .getFamilyProfilesUsecase
          .repository
          .updateFamilyProfile(memberId, request);

      // If updated member is the owner, refresh current account to update UI
      if (isOwnerUpdate) {
        // Clear cache first
        await CurrentAccountCacheService.clearCache();
        // Dispatch event to AuthBloc to refresh current account
        // This will update UI in HomeScreen and ProfileScreen automatically
        try {
          final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
          authBloc.add(const AuthLoadCurrentAccount());
        } catch (e) {
          // AuthBloc not found in context - UI won't be updated automatically
          // This should not happen in normal flow as FamilyProfileScreen is
          // navigated from ProfileScreen which has AuthBloc in AppScaffold
        }
      }

      if (mounted) {
        AppLoading.hide(context);
        Navigator.of(context).pop();
        AppToast.showSuccess(context, message: AppStrings.updateSuccess);
        context.read<FamilyProfileBloc>().add(const FamilyProfileRefreshed());
      }
    } catch (e) {
      if (mounted) {
        AppLoading.hide(context);
        AppToast.showError(context, message: '${AppStrings.updateFailed}: $e');
      }
    }
  }

  void _showDeleteConfirmDialog(FamilyProfileEntity member) {
    final bloc = this.context.read<FamilyProfileBloc>();
    showDialog(
      context: this.context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text(AppStrings.confirmDeleteMessage.replaceAll('{name}', member.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              AppLoading.show(this.context, message: AppStrings.processing);
              try {
                await bloc
                    .getFamilyProfilesUsecase
                    .repository
                    .deleteFamilyProfile(member.id);
                if (mounted) {
                  AppLoading.hide(this.context);
                  AppToast.showSuccess(this.context, message: 'Xóa thành công');
                  bloc.add(const FamilyProfileRefreshed());
                }
              } catch (e) {
                if (mounted) {
                  AppLoading.hide(this.context);
                  AppToast.showError(this.context, message: 'Xóa thất bại: $e');
                }
              }
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<FamilyProfileBloc, FamilyProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppAppBar(
            title: AppStrings.familyProfileTitle,
            centerTitle: true,
            titleFontSize: 20 * scale,
            titleFontWeight: FontWeight.w700,
          ),
          body: state.isLoading
              ? const Center(
                  child: AppLoadingIndicator(
                    color: AppColors.primary,
                  ),
                )
              : state.members.isEmpty
                  ? _buildEmptyState(scale)
                  : _buildMembersList(scale, state.members, state.memberTypes),
          floatingActionButton: AppWidgets.primaryFabExtendedIconOnly(
            context: context,
            icon: Icons.add_rounded,
            onPressed: _showAddMemberDrawer,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.family_restroom_rounded,
                size: 64 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              AppStrings.noFamilyMembers,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              AppStrings.addFirstMember,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberOptions(FamilyProfileEntity member, String? typeName) {
    final scale = AppResponsive.scaleFactor(context);
    final height = MediaQuery.of(context).size.height;
    final isMomOrBaby = typeName?.toLowerCase() == 'mom' || typeName?.toLowerCase() == 'baby';

    if (!isMomOrBaby) {
      _showEditMemberDrawer(member);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: height * 0.9,
        ),
        padding: EdgeInsets.all(24 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28 * scale)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24 * scale,
                  backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: member.avatarUrl == null ? Icon(Icons.person_rounded, color: AppColors.primary, size: 24 * scale) : null,
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: AppTextStyles.tinos(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        _translateMemberType(typeName ?? ''),
                        style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            SizedBox(height: 24 * scale),
            _buildOptionItem(
              scale,
              icon: Icons.person_outline_rounded,
              title: 'Thông tin cá nhân',
              subtitle: 'Xem và chỉnh sửa thông tin thành viên',
              onTap: () {
                Navigator.pop(context);
                _showEditMemberDrawer(member);
              },
            ),
            SizedBox(height: 12 * scale),
            _buildOptionItem(
              scale,
              icon: Icons.medical_information_outlined,
              title: 'Hồ sơ sức khoẻ',
              subtitle: 'Theo dõi tình trạng sức khoẻ định kỳ',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => InjectionContainer.healthRecordBloc,
                      child: HealthRecordScreen(
                        familyProfileId: member.id,
                        isBaby: typeName?.toLowerCase() == 'baby',
                        memberName: member.fullName,
                        avatarUrl: member.avatarUrl,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    double scale, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * scale),
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: (color ?? AppColors.textSecondary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? AppColors.textSecondary, size: 24 * scale),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.arimo(fontSize: 16 * scale, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20 * scale),
          ],
        ),
      ),
    );
  }

  String _translateMemberType(String type) {
    switch (type.toLowerCase()) {
      case 'head of family':
        return 'Chủ hộ';
      case 'mom':
        return 'Mẹ';
      case 'baby':
        return 'Bé';
      default:
        return type;
    }
  }

  Widget _buildMembersList(
    double scale,
    List<FamilyProfileEntity> members,
    List<MemberTypeModel> memberTypes,
  ) {
    final sortedMembers = List<FamilyProfileEntity>.from(members)
      ..sort((a, b) {
        if (a.isOwner) return -1;
        if (b.isOwner) return 1;
        return a.fullName.compareTo(b.fullName);
      });

    final typeNameById = {
      for (final t in memberTypes) t.id: t.name,
    };

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FamilyProfileBloc>().add(const FamilyProfileRefreshed());
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8 * scale),
        itemCount: sortedMembers.length,
        itemBuilder: (context, index) {
          final member = sortedMembers[index];
          final typeName = member.memberTypeId != null
              ? typeNameById[member.memberTypeId]
              : null;
          return FamilyMemberCard(
            member: member,
            memberTypeName: typeName,
            onTap: () => _showMemberOptions(member, typeName),
            onEdit: () => _showEditMemberDrawer(member),
            onDelete: () => _showDeleteConfirmDialog(member),
          );
        },
      ),
    );
  }
}
