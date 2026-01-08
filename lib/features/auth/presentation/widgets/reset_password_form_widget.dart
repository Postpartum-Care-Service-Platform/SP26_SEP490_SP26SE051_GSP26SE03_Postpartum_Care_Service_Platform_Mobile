import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Reset Password Form Widget - email field + reset button
class ResetPasswordFormWidget extends StatefulWidget {
  const ResetPasswordFormWidget({super.key});

  @override
  State<ResetPasswordFormWidget> createState() => _ResetPasswordFormWidgetState();
}

class _ResetPasswordFormWidgetState extends State<ResetPasswordFormWidget> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPressed() {
    if (_formKey.currentState?.validate() == true) {
      context.read<AuthBloc>().add(
            AuthForgotPassword(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppWidgets.textInput(
            label: AppStrings.email,
            placeholder: AppStrings.emailPlaceholder,
            controller: _emailController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.errorInputEmailRequired;
              }
              if (!value.contains('@')) {
                return AppStrings.errorInputEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 23.992),
          AppWidgets.primaryButton(
            text: AppStrings.resetPassword,
            onPressed: _onResetPressed,
          ),
        ],
      ),
    );
  }
}

