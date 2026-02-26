import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../domain/entities/package_entity.dart';

class PackageCard extends StatelessWidget {
  final PackageEntity package;
  final VoidCallback? onTap;

  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
  });

  String _formatPrice(double price) {
    // Format price as Vietnamese currency (VND)
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    
    // Format with thousand separators
    final buffer = StringBuffer();
    final length = priceStr.length;
    
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString() + AppStrings.currencyUnit;
  }

  IconData _getPackageIcon(String packageName) {
    final name = packageName.toLowerCase();
    if (name.contains('vip')) {
      return Icons.diamond_outlined;
    } else if (name.contains('pro')) {
      return Icons.star_outline;
    } else {
      return Icons.card_giftcard_outlined;
    }
  }

  Color _getGradientColor(String packageName) {
    final name = packageName.toLowerCase();
    if (name.contains('vip')) {
      return AppColors.packageVip;
    } else if (name.contains('pro')) {
      return AppColors.packagePro;
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final gradientColor = _getGradientColor(package.packageName);
    final icon = _getPackageIcon(package.packageName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColor.withValues(alpha: 0.15),
              gradientColor.withValues(alpha: 0.05),
              AppColors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: gradientColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColor.withValues(alpha: 0.2),
              blurRadius: 12 * scale,
              offset: Offset(0, 6 * scale),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * scale),
          child: Stack(
            children: [
              // Decorative circle in top right
              Positioned(
                top: -30 * scale,
                right: -30 * scale,
                child: Container(
                  width: 100 * scale,
                  height: 100 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gradientColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top section: Icon and badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10 * scale),
                          decoration: BoxDecoration(
                            color: gradientColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                          child: Icon(
                            icon,
                            size: 28 * scale,
                            color: gradientColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * scale,
                            vertical: 5 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: gradientColor,
                            borderRadius: BorderRadius.circular(18 * scale),
                          ),
                          child: Text(
                            package.durationDays != null
                                ? '${package.durationDays} ${AppStrings.days}'
                                : AppStrings.days,
                            style: AppTextStyles.arimo(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * scale),
                    // Package name
                    Text(
                      package.packageName,
                      style: AppTextStyles.tinos(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6 * scale),
                    // Description - Flexible to prevent overflow
                    if (package.description.isNotEmpty)
                      Flexible(
                        child: Text(
                          package.description,
                          style: AppTextStyles.arimo(
                            fontSize: 11 * scale,
                            color: AppColors.textSecondary,
                          ).copyWith(height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    SizedBox(height: 12 * scale),
                    // Price section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4 * scale,
                            offset: Offset(0, 2 * scale),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _formatPrice(package.basePrice),
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.bold,
                                color: gradientColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14 * scale,
                            color: gradientColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
