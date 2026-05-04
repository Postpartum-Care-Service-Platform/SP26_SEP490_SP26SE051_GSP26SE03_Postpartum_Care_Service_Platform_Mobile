import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
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
import '../../../wallet/presentation/bloc/wallet_cubit.dart';
import '../../../wallet/presentation/bloc/wallet_state.dart';
import 'package:intl/intl.dart';

/// Redesigned premium Bottom sheet form for withdraw requests
class CreateHomeStaffWithdrawSheet extends StatefulWidget {
  final BuildContext parentContext;

  const CreateHomeStaffWithdrawSheet({super.key, required this.parentContext});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => InjectionContainer.refundRequestBloc),
          BlocProvider(
            create: (_) => WalletCubit(
              remoteDataSource: InjectionContainer.walletRemoteDataSource,
            )..loadWallet(),
          ),
        ],
        child: CreateHomeStaffWithdrawSheet(parentContext: context),
      ),
    );
  }

  @override
  State<CreateHomeStaffWithdrawSheet> createState() =>
      _CreateHomeStaffWithdrawSheetState();
}

class _CreateHomeStaffWithdrawSheetState
    extends State<CreateHomeStaffWithdrawSheet> {
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _reasonController = TextEditingController();

  List<VietQrBank> _banks = const [];
  bool _isLoadingBanks = false;
  double _walletBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    if (_isLoadingBanks) return;
    if (mounted) setState(() => _isLoadingBanks = true);

    try {
      final items = await InjectionContainer.getVietQrBanks.execute();
      if (!mounted) return;
      setState(() => _banks = items);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingBanks = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _amountController.text.trim().isNotEmpty &&
      _bankNameController.text.trim().isNotEmpty &&
      _accountNumberController.text.trim().isNotEmpty &&
      _accountHolderController.text.trim().isNotEmpty &&
      _reasonController.text.trim().isNotEmpty;

  Future<void> _handleSubmit() async {
    if (!_isFormValid) {
      AppToast.showWarning(context, message: 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    final amountText = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final amount = int.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      AppToast.showWarning(context, message: 'Số tiền rút phải lớn hơn 0');
      return;
    }

    if (amount > _walletBalance) {
      AppToast.showWarning(
        context,
        message:
            'Số tiền không được vượt quá số dư (${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_walletBalance)})',
      );
      return;
    }

    final confirmed = await AppWidgets.showConfirmDialog(
      context,
      title: 'Xác nhận rút tiền',
      message:
          'Hệ thống sẽ xử lý yêu cầu rút tiền của bạn. Bạn có chắc chắn muốn tiếp tục?',
      confirmText: 'Xác nhận',
      cancelText: AppStrings.cancel,
      confirmColor: AppColors.primary,
      icon: Icons.account_balance_wallet_rounded,
    );

    if (confirmed != true || !mounted || !context.mounted) return;

    AppLoading.show(widget.parentContext, message: AppStrings.processing);

    context.read<RefundRequestBloc>().add(
      HomeStaffWithdrawRequested(
        requestedAmount: amount,
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return MultiBlocListener(
      listeners: [
        BlocListener<RefundRequestBloc, RefundRequestState>(
          listener: (context, state) {
            if (state is RefundRequestCreated) {
              AppLoading.hide(widget.parentContext);
              Navigator.of(context).pop();
              AppToast.showSuccess(
                widget.parentContext,
                message: 'Gửi yêu cầu rút tiền thành công',
              );
              AppRouter.push(widget.parentContext, AppRoutes.refundHistory);
            } else if (state is RefundRequestError) {
              AppLoading.hide(widget.parentContext);
              AppToast.showError(widget.parentContext, message: state.message);
            }
          },
        ),
        BlocListener<WalletCubit, WalletState>(
          listener: (context, state) {
            if (state is WalletLoaded) {
              setState(() => _walletBalance = state.wallet.balance);
            }
          },
        ),
      ],
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(scale),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  12 * scale,
                  24 * scale,
                  24 * scale + bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(scale),
                    SizedBox(height: 24 * scale),
                    _buildSectionTitle('Thông tin số tiền', scale),
                    SizedBox(height: 12 * scale),
                    _buildInputField(
                      label: 'Số tiền muốn rút',
                      placeholder: '0 đ',
                      controller: _amountController,
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      scale: scale,
                    ),
                    SizedBox(height: 24 * scale),
                    _buildSectionTitle('Thông tin ngân hàng', scale),
                    SizedBox(height: 12 * scale),
                    _buildBankPickerField(scale),
                    SizedBox(height: 16 * scale),
                    _buildInputField(
                      label: 'Số tài khoản',
                      placeholder: 'Nhập số tài khoản...',
                      controller: _accountNumberController,
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      scale: scale,
                    ),
                    SizedBox(height: 16 * scale),
                    _buildInputField(
                      label: 'Chủ tài khoản',
                      placeholder: 'Nhập tên chủ tài khoản...',
                      controller: _accountHolderController,
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.characters,
                      scale: scale,
                    ),
                    SizedBox(height: 24 * scale),
                    _buildSectionTitle('Lý do', scale),
                    SizedBox(height: 12 * scale),
                    _buildQuickReasons(scale),
                    SizedBox(height: 12 * scale),
                    _buildTextAreaField(
                      placeholder:
                          'Nhập lý do rút tiền (ví dụ: Rút lương, chi phí sinh hoạt...)',
                      controller: _reasonController,
                      scale: scale,
                    ),
                    SizedBox(height: 32 * scale),
                    _buildSubmitButton(scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12 * scale),
        Container(
          width: 48 * scale,
          height: 5 * scale,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 16 * scale,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10 * scale),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                  size: 24 * scale,
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yêu cầu rút tiền',
                      style: AppTextStyles.arimo(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Gửi yêu cầu thanh toán từ ví nhân viên',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  padding: EdgeInsets.all(8 * scale),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.background),
      ],
    );
  }

  Widget _buildBalanceCard(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_moon_outlined,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16 * scale,
              ),
              SizedBox(width: 8 * scale),
              Text(
                'Số dư khả dụng',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              if (state is WalletLoading) {
                return const CircularProgressIndicator(color: Colors.white);
              }
              return Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(_walletBalance),
                style: AppTextStyles.arimo(
                  fontSize: 28 * scale,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Text(
      title,
      style: AppTextStyles.arimo(
        fontSize: 15 * scale,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required IconData icon,
    required double scale,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.third,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primary,
                size: 20 * scale,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 16 * scale,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankPickerField(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngân hàng thụ hưởng',
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8 * scale),
        InkWell(
          onTap: _showBankPicker,
          borderRadius: BorderRadius.circular(16 * scale),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 16 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: 20 * scale,
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Text(
                    _bankNameController.text.isNotEmpty
                        ? _bankNameController.text
                        : 'Chọn ngân hàng...',
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: _bankNameController.text.isNotEmpty
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _bankNameController.text.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.third,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 24 * scale,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required String placeholder,
    required TextEditingController controller,
    required double scale,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        minLines: 3,
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
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16 * scale),
        ),
      ),
    );
  }

  Widget _buildQuickReasons(double scale) {
    final reasons = [
      'Rút tiền về ngân hàng',
      'Rút lương',
      'Ứng lương',
      'Tất toán số dư ví',
      'Rút tiền thưởng/hoa hồng',
    ];

    return Wrap(
      spacing: 8 * scale,
      runSpacing: 8 * scale,
      children: reasons.map((reason) {
        final isSelected = _reasonController.text == reason;
        return InkWell(
          onTap: () {
            setState(() {
              _reasonController.text = reason;
            });
          },
          borderRadius: BorderRadius.circular(12 * scale),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 8 * scale,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              reason,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(double scale) {
    final bool isEnabled = _isFormValid;
    return Container(
      width: double.infinity,
      height: 56 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18 * scale),
        gradient: isEnabled
            ? LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.9),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isEnabled ? null : const Color(0xFFE2E8F0),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleSubmit : null,
          borderRadius: BorderRadius.circular(18 * scale),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_rounded,
                  color: isEnabled ? Colors.white : AppColors.third,
                  size: 20 * scale,
                ),
                SizedBox(width: 12 * scale),
                Text(
                  'Gửi yêu cầu rút tiền',
                  style: AppTextStyles.arimo(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: isEnabled ? Colors.white : AppColors.third,
                  ),
                ),
              ],
            ),
          ),
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
                  bank.code.toLowerCase().contains(keyword);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  _buildBankPickerHeader(
                    scale,
                    searchController,
                    (val) => setModalState(() {}),
                  ),
                  Expanded(
                    child: banks.isEmpty
                        ? _buildEmptyBanks(scale)
                        : GridView.builder(
                            padding: EdgeInsets.all(24 * scale),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16 * scale,
                                  mainAxisSpacing: 16 * scale,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: banks.length,
                            itemBuilder: (context, index) {
                              final bank = banks[index];
                              return _buildBankItem(bank, scale);
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
  }

  Widget _buildBankPickerHeader(
    double scale,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        12 * scale,
        24 * scale,
        16 * scale,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            width: 40 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 20 * scale),
          Row(
            children: [
              Text(
                'Chọn ngân hàng',
                style: AppTextStyles.arimo(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ngân hàng...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.third,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankItem(VietQrBank bank, double scale) {
    final bool isSelected = _bankNameController.text == bank.displayName;
    return InkWell(
      onTap: () {
        setState(() => _bankNameController.text = bank.displayName);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(20 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (bank.logo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8 * scale),
                child: Image.network(
                  bank.logo,
                  height: 40 * scale,
                  fit: BoxFit.contain,
                ),
              )
            else
              Icon(
                Icons.account_balance_rounded,
                size: 32 * scale,
                color: AppColors.primary,
              ),
            SizedBox(height: 12 * scale),
            Text(
              bank.shortName.isNotEmpty ? bank.shortName : bank.code,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBanks(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 64 * scale,
            color: AppColors.third.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16 * scale),
          Text(
            'Không tìm thấy ngân hàng phù hợp',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.third,
            ),
          ),
        ],
      ),
    );
  }
}
