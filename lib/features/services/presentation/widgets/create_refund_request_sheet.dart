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
import '../../domain/entities/vietqr_bank.dart';
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

  List<VietQrBank> _banks = const [];
  bool _isLoadingBanks = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    if (_isLoadingBanks) return;

    if (mounted) {
      setState(() {
        _isLoadingBanks = true;
      });
    }

    try {
      final items = await InjectionContainer.getVietQrBanks.execute();
      
      if (!mounted) return;
      setState(() {
        _banks = items;
      });
    } catch (_) {
      // fallback silently; user can still type/select if needed
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBanks = false;
        });
      }
    }
  }

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
          _buildBankPickerField(scale),
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

  Widget _buildBankPickerField(double scale) {
    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: _showBankPicker,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 16 * scale,
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_outlined,
              color: AppColors.third,
              size: 20 * scale,
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: _isLoadingBanks
                  ? Row(
                      children: [
                        SizedBox(
                          width: 14 * scale,
                          height: 14 * scale,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Đang tải danh sách ngân hàng...',
                          style: AppTextStyles.arimo(
                            fontSize: 13 * scale,
                            color: AppColors.third,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _bankNameController.text.trim().isNotEmpty
                          ? _bankNameController.text.trim()
                          : AppStrings.refundRequestBankNamePlaceholder,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: _bankNameController.text.trim().isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.third,
                      ),
                    ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 22 * scale,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBankPicker() async {
    final scale = AppResponsive.scaleFactor(context);
    final searchController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final keyword = searchController.text.trim().toLowerCase();
            final banks = _banks.where((bank) {
              return bank.displayName.toLowerCase().contains(keyword) ||
                  bank.shortName.toLowerCase().contains(keyword) ||
                  bank.code.toLowerCase().contains(keyword) ||
                  bank.bin.contains(keyword);
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24 * scale),
                  topRight: Radius.circular(24 * scale),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12 * scale, bottom: 8 * scale),
                    width: 40 * scale,
                    height: 4 * scale,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2 * scale),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                      vertical: 12 * scale,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.refundRequestBankName,
                            style: AppTextStyles.tinos(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textPrimary,
                            size: 24 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(color: AppColors.borderLight, width: 1.5),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        style: AppTextStyles.arimo(fontSize: 14 * scale),
                        decoration: InputDecoration(
                          hintText: 'Tìm ngân hàng...',
                          hintStyle: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                            size: 22 * scale,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16 * scale,
                            vertical: 14 * scale,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Expanded(
                    child: banks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_outlined,
                                  size: 48 * scale,
                                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  'Không tìm thấy ngân hàng',
                                  style: AppTextStyles.arimo(
                                    fontSize: 14 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 30 * scale),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12 * scale,
                              mainAxisSpacing: 16 * scale,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: banks.length,
                            itemBuilder: (context, index) {
                              final bank = banks[index];
                              final isSelected = _bankNameController.text.trim() == bank.displayName;
                              
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _bankNameController.text = bank.displayName;
                                  });
                                  Navigator.of(bottomSheetContext).pop();
                                },
                                borderRadius: BorderRadius.circular(12 * scale),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.white,
                                    borderRadius: BorderRadius.circular(12 * scale),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.borderLight.withValues(alpha: 0.5),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected ? [] : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(8 * scale),
                                          child: bank.logo.isNotEmpty
                                              ? Image.network(
                                                  bank.logo,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) => Icon(
                                                    Icons.account_balance_rounded,
                                                    size: 24 * scale,
                                                    color: AppColors.primary,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.account_balance_rounded,
                                                  size: 24 * scale,
                                                  color: AppColors.primary,
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.topCenter,
                                          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                                          child: Text(
                                            bank.shortName.isNotEmpty ? bank.shortName : bank.code,
                                            style: AppTextStyles.arimo(
                                              fontSize: 11 * scale,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    searchController.dispose();
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
