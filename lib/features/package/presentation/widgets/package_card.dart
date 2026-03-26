import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/package_entity.dart';

class PackageCard extends StatelessWidget {
  final PackageEntity package;
  final VoidCallback? onTap;
  final bool isUnavailable;

  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
    this.isUnavailable = false,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }

    return '${buffer.toString()}${AppStrings.currencyUnit}';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * scale),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (package.imageUrl != null && package.imageUrl!.isNotEmpty)
                  Image.network(
                    package.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(scale),
                  )
                else
                  _fallbackImage(scale),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.24),
                          Colors.black.withValues(alpha: 0.62),
                        ],
                        stops: const [0.0, 0.45, 0.72, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 88 * scale,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.70),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12 * scale,
                  right: 8 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                    child: Text(
                      package.durationDays != null
                          ? '${package.durationDays} ${AppStrings.days}'
                          : AppStrings.days,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12 * scale,
                  left: 12 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hotel_rounded,
                          size: 12 * scale,
                          color: AppColors.textOnPrimary,
                        ),
                        SizedBox(width: 5 * scale),
                        Text(
                          package.roomTypeName ?? 'Chưa có loại phòng',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ).copyWith(
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 3 * scale,
                                offset: Offset(0, 1 * scale),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10 * scale,
                  right: 110 * scale,
                  bottom: 8 * scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.packageName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.tinos(
                          fontSize: package.packageName.length > 24
                              ? 26 * scale
                              : 28 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ).copyWith(height: 1.05),
                      ),
                      Text(
                        _formatPrice(package.basePrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.arimo(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10 * scale,
                  bottom: 10 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Text(
                      'Còn ${package.availableRooms ?? 0}/${package.totalRooms ?? 0} phòng',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                if (isUnavailable)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20 * scale),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * scale,
                            vertical: 10 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hết phòng',
                                style: AppTextStyles.arimo(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                package.unavailableFrom != null &&
                                        package.unavailableTo != null
                                    ? 'Từ ${_formatDate(package.unavailableFrom)} đến ${_formatDate(package.unavailableTo)}'
                                    : 'Hiện tại chưa còn phòng trống',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  color: AppColors.white.withValues(alpha: 0.95),
                                ),
                              ),
                              if (package.firstAvailableDate != null) ...[
                                SizedBox(height: 2 * scale),
                                Text(
                                  'Trống lại: ${_formatDate(package.firstAvailableDate)}',
                                  style: AppTextStyles.arimo(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFFD166),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
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

  Widget _fallbackImage(double scale) {
    return Container(
      color: AppColors.borderLight,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 34 * scale,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
