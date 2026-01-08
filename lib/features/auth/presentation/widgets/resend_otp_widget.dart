import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Resend OTP Widget - Displays countdown timer and resend OTP link
class ResendOtpWidget extends StatefulWidget {
  final VoidCallback onResendOtp;

  const ResendOtpWidget({
    super.key,
    required this.onResendOtp,
  });

  @override
  State<ResendOtpWidget> createState() => _ResendOtpWidgetState();
}

class _ResendOtpWidgetState extends State<ResendOtpWidget> {
  Timer? _resendTimer;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleResendOtp() {
    widget.onResendOtp();
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Center(
      child: _resendCountdown > 0
          ? Text(
              AppStrings.resendOtpCountdown.replaceAll(
                '{seconds}',
                _resendCountdown.toString(),
              ),
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            )
          : AppWidgets.linkText(
              text: AppStrings.resendOtp,
              onTap: _handleResendOtp,
            ),
    );
  }
}

