import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/domain/entities/create_customer_result_entity.dart';

class EmployeeCreateCustomerScreen extends StatefulWidget {
  const EmployeeCreateCustomerScreen({super.key});

  @override
  State<EmployeeCreateCustomerScreen> createState() =>
      _EmployeeCreateCustomerScreenState();
}

class _EmployeeCreateCustomerScreenState
    extends State<EmployeeCreateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await InjectionContainer.authRepository.createCustomer(
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        username:
            _usernameCtrl.text.trim().isEmpty ? null : _usernameCtrl.text.trim(),
      );

      if (!mounted) return;
      await _showSuccessDialog(result);
      _formKey.currentState?.reset();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _usernameCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSuccessDialog(CreateCustomerResultEntity result) async {
    final scale = AppResponsive.scaleFactor(context);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tạo khách hàng thành công'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.message),
              SizedBox(height: 12 * scale),
              Text(
                'Email: ${result.email}',
                style: AppTextStyles.arimo(fontWeight: FontWeight.w700),
              ),
              if (result.username != null && result.username!.isNotEmpty) ...[
                SizedBox(height: 6 * scale),
                Text('Username: ${result.username}'),
              ],
              if (result.phone != null && result.phone!.isNotEmpty) ...[
                SizedBox(height: 6 * scale),
                Text('SĐT: ${result.phone}'),
              ],
              SizedBox(height: 12 * scale),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mật khẩu tạm: ${result.temporaryPassword}',
                        style: AppTextStyles.arimo(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: result.temporaryPassword),
                        );
                        if (context.mounted) {
                          AppToast.showSuccess(
                            context,
                            message: 'Đã copy mật khẩu tạm',
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                'Lưu ý: Vui lòng yêu cầu khách hàng đổi mật khẩu sau khi đăng nhập.',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppAppBar(
        title: 'Tạo tài khoản khách hàng',
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Staff có thể tạo nhanh tài khoản khách hàng để thuận tiện hỗ trợ.',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14 * scale),
                _Input(
                  label: 'Email *',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Vui lòng nhập email';
                    if (!value.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                SizedBox(height: 12 * scale),
                _Input(
                  label: 'Số điện thoại (tuỳ chọn)',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12 * scale),
                _Input(
                  label: 'Tên đăng nhập (tuỳ chọn)',
                  controller: _usernameCtrl,
                ),
                SizedBox(height: 18 * scale),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 18 * scale,
                          width: 18 * scale,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Tạo khách hàng',
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Input({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8 * scale),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14 * scale),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14 * scale),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14 * scale),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

