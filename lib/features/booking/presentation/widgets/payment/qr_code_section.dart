import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/payment_link_entity.dart';

class QRCodeSection extends StatelessWidget {
  final PaymentLinkEntity paymentLink;

  const QRCodeSection({
    super.key,
    required this.paymentLink,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20 * scale,
            offset: Offset(0, 4 * scale),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                size: 20 * scale,
                color: AppColors.primary,
              ),
              SizedBox(width: 8 * scale),
              Text(
                AppStrings.paymentQRCode,
                style: AppTextStyles.arimo(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ).copyWith(letterSpacing: 0.3),
              ),
            ],
          ),
          SizedBox(height: 24 * scale),
          Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white,
                  AppColors.background,
                ],
              ),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: QrImageView(
                    data: paymentLink.qrCode,
                    version: QrVersions.auto,
                    size: 220 * scale,
                    padding: EdgeInsets.zero,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Container(
                    width: 55 * scale,
                    height: 55 * scale,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.appIconThird,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16 * scale,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6 * scale),
                Flexible(
                  child: Text(
                    AppStrings.paymentScanQR,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
