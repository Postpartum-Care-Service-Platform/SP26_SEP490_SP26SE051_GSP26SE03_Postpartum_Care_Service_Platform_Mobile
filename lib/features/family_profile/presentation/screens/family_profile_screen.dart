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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text(AppStrings.confirmDeleteMessage.replaceAll('{name}', member.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.deleteFeatureUnderDevelopment)),
              );
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
          appBar: AppBar(
            title: Text(
              AppStrings.familyProfileTitle,
              style: AppTextStyles.tinos(
                fontSize: 24 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20 * scale,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
          floatingActionButton: AppWidgets.primaryFabExtended(
            context: context,
            text: AppStrings.addFamilyMember,
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

  Widget _buildMembersList(
    double scale,
    List<FamilyProfileEntity> members,
    List<MemberTypeModel> memberTypes,
  ) {
    // Sort: owner first, then by name
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
            onTap: () => _showEditMemberDrawer(member),
            onEdit: () => _showEditMemberDrawer(member),
            onDelete: () => _showDeleteConfirmDialog(member),
          );
        },
      ),
    );
  }
}
