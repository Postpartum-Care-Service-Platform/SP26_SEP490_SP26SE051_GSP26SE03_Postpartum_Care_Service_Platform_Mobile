import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../bloc/refund_request/refund_request_bloc.dart';
import '../bloc/refund_request/refund_request_event.dart';
import '../bloc/refund_request/refund_request_state.dart';

/// Bottom sheet form to create a refund request
class CreateRefundRequestSheet extends StatefulWidget {
  final int bookingId;
  final BuildContext parentContext;

  const CreateRefundRequestSheet({
    super.key,
    required this.bookingId,
    required this.parentContext,
  });

  /// Show this sheet as a modal bottom sheet
  static Future<void> show(BuildContext context, {required int bookingId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => InjectionContainer.refundRequestBloc,
        child: CreateRefundRequestSheet(
          bookingId: bookingId,
          parentContext: context,
        ),
      ),
    );
  }

  @override
  State<CreateRefundRequestSheet> createState() =>
      _CreateRefundRequestSheetState();
}

class _CreateRefundRequestSheetState extends State<CreateRefundRequestSheet> {
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _bankNameController.text.trim().isNotEmpty &&
      _accountNumberController.text.trim().isNotEmpty &&
      _accountHolderController.text.trim().isNotEmpty &&
      _reasonController.text.trim().isNotEmpty;

  Future<void> _handleSubmit() async {
    if (!_isFormValid) {
      AppToast.showWarning(
        context,
        message: AppStrings.refundRequestFillAllFields,
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await AppWidgets.showConfirmDialog(
      context,
      title: AppStrings.refundRequestConfirmTitle,
      message: AppStrings.refundRequestConfirmMessage,
      confirmText: AppStrings.refundRequestConfirmButton,
      cancelText: AppStrings.cancel,
      confirmColor: AppColors.appointmentCancelled,
      icon: Icons.warning_amber_rounded,
    );

    if (confirmed != true || !mounted || !context.mounted) return;

    // Show loading on parent context
    AppLoading.show(widget.parentContext, message: AppStrings.processing);

    context.read<RefundRequestBloc>().add(
          RefundRequestCreateRequested(
            bookingId: widget.bookingId,
            bankName: _bankNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            accountHolder: _accountHolderController.text.trim(),
            reason: _reasonController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocListener<RefundRequestBloc, RefundRequestState>(
      listener: (context, state) {
        if (state is RefundRequestCreated) {
          AppLoading.hide(widget.parentContext);
          Navigator.of(context).pop();
          AppToast.showSuccess(
            widget.parentContext,
            message: AppStrings.refundRequestSuccess,
          );
          AppRouter.push(widget.parentContext, AppRoutes.refundHistory);
        } else if (state is RefundRequestError) {
          AppLoading.hide(widget.parentContext);
          AppToast.showError(
            widget.parentContext,
            message: state.message,
          );
        }
      },
      child: AppDrawerForm(
        title: AppStrings.refundRequestTitle,
        isLoading: context.watch<RefundRequestBloc>().state
            is RefundRequestLoading,
        isDisabled: !_isFormValid,
        saveButtonText: AppStrings.refundRequestCreate,
        saveButtonIcon: Icons.send_rounded,
        onSave: _handleSubmit,
        children: [
          // Warning banner
          _buildWarningBanner(scale),
          SizedBox(height: 16 * scale),

          // Booking ID info
          _buildBookingIdInfo(scale),
          SizedBox(height: 20 * scale),

          // Bank Name
          _buildFieldLabel(AppStrings.refundRequestBankName, scale),
          SizedBox(height: 8 * scale),
          _buildTextField(
            placeholder: AppStrings.refundRequestBankNamePlaceholder,
            controller: _bankNameController,
            icon: Icons.account_balance_outlined,
            scale: scale,
          ),
          SizedBox(height: 16 * scale),

          // Account Number
          _buildFieldLabel(AppStrings.refundRequestAccountNumber, scale),
          SizedBox(height: 8 * scale),
          _buildTextField(
            placeholder: AppStrings.refundRequestAccountNumberPlaceholder,
            controller: _accountNumberController,
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            scale: scale,
          ),
          SizedBox(height: 16 * scale),

          // Account Holder
          _buildFieldLabel(AppStrings.refundRequestAccountHolder, scale),
          SizedBox(height: 8 * scale),
          _buildTextField(
            placeholder: AppStrings.refundRequestAccountHolderPlaceholder,
            controller: _accountHolderController,
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            scale: scale,
          ),
          SizedBox(height: 16 * scale),

          // Reason
          _buildFieldLabel(AppStrings.refundRequestReason, scale),
          SizedBox(height: 8 * scale),
          _buildReasonField(scale),
          SizedBox(height: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, double scale) {
    return Text(
      label,
      style: AppTextStyles.arimo(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildWarningBanner(double scale) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.appointmentCancelled.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.appointmentCancelled.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6 * scale),
            decoration: BoxDecoration(
              color: AppColors.appointmentCancelled.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.appointmentCancelled,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lưu ý quan trọng',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.appointmentCancelled,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Yêu cầu hoàn tiền sẽ được xem xét bởi quản trị viên. '
                  'Số tiền hoàn lại sẽ tính theo số ngày chưa thực hiện dịch vụ.',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingIdInfo(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            color: AppColors.primary,
            size: 20 * scale,
          ),
          SizedBox(width: 10 * scale),
          Text(
            '${AppStrings.refundRequestBookingId}: ',
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '#${widget.bookingId}',
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String placeholder,
    required TextEditingController controller,
    required IconData icon,
    required double scale,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.arimo(
          fontSize: 14 * scale,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.third,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.third,
            size: 20 * scale,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 16 * scale,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildReasonField(double scale) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _reasonController,
        maxLines: 4,
        minLines: 3,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.arimo(
          fontSize: 14 * scale,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.refundRequestReasonPlaceholder,
          hintStyle: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.third,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.all(16 * scale),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
