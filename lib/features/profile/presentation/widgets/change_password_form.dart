import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Change password form widget
class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          AuthChangePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmNewPassword: _confirmNewPasswordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthChangePasswordSuccess) {
          // Clear form fields
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
          // Toast and reload will be handled by AccountDetailsScreen
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppWidgets.textInput(
              label: AppStrings.currentPassword,
              placeholder: AppStrings.currentPasswordPlaceholder,
              controller: _currentPasswordController,
              isPassword: true,
              obscureText: _obscureCurrent,
              onTogglePassword: () {
                setState(() {
                  _obscureCurrent = !_obscureCurrent;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.errorInputPasswordRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppWidgets.textInput(
              label: AppStrings.password,
              placeholder: AppStrings.passwordPlaceholder,
              controller: _newPasswordController,
              isPassword: true,
              obscureText: _obscureNew,
              onTogglePassword: () {
                setState(() {
                  _obscureNew = !_obscureNew;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.errorInputPasswordRequired;
                }
                if (value.length < 6) {
                  return AppStrings.errorInputPasswordMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppWidgets.textInput(
              label: AppStrings.confirmPassword,
              placeholder: AppStrings.confirmPasswordPlaceholder,
              controller: _confirmNewPasswordController,
              isPassword: true,
              obscureText: _obscureConfirm,
              onTogglePassword: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.errorInputConfirmPassword;
                }
                if (value != _newPasswordController.text) {
                  return AppStrings.errorInputPasswordsNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return AppWidgets.primaryButton(
                  text: AppStrings.saveNewPassword,
                  onPressed: isLoading ? () {} : _submit,
                  isEnabled: !isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
