import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Loại dịch vụ: tại trung tâm hay tại nhà
enum ServiceLocationType {
  center,
  home,
}

/// Màn chọn loại dịch vụ trước khi vào flow đặt gói
class ServiceLocationSelection extends StatelessWidget {
  final ValueChanged<ServiceLocationType> onLocationSelected;

  const ServiceLocationSelection({
    super.key,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  children: [
                    _LocationHalfCard(
                      key: const ValueKey('center_location_card'),
                      isTop: true,
                      title: AppStrings.servicesLocationCenterTitle,
                      subtitle: AppStrings.servicesLocationCenterSubtitle,
                      chipLabel: AppStrings.servicesLocationCenterChip,
                      accentColor: AppColors.packageVip,
                      backgroundImageAsset: AppAssets.walkInService,
                      onTap: () => onLocationSelected(ServiceLocationType.center),
                    ),
                    _LocationHalfCard(
                      key: const ValueKey('home_location_card'),
                      isTop: false,
                      title: AppStrings.servicesLocationHomeTitle,
                      subtitle: AppStrings.servicesLocationHomeSubtitle,
                      chipLabel: AppStrings.servicesLocationHomeChip,
                      accentColor: AppColors.packagePro,
                      backgroundImageAsset: AppAssets.homeCareService,
                      onTap: () => onLocationSelected(ServiceLocationType.home),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LocationHalfCard extends StatelessWidget {
  final bool isTop;
  final String title;
  final String subtitle;
  final String chipLabel;
  final Color accentColor;
  final String backgroundImageAsset;
  final VoidCallback onTap;

  const _LocationHalfCard({
    super.key,
    required this.isTop,
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.accentColor,
    required this.backgroundImageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final radius = 16.0 * scale; // theo guideline: 12-16px (scaled)
    final contentPadding = EdgeInsets.all(20 * scale);
    final contentAlign = isTop ? Alignment.centerLeft : Alignment.centerRight;
    final textAlign = isTop ? TextAlign.left : TextAlign.right;
    final contentCrossAxisAlignment =
        isTop ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 16 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                      end: isTop ? Alignment.bottomRight : Alignment.topLeft,
                      colors: [
                        accentColor.withValues(alpha: 0.8),
                        accentColor.withValues(alpha: 0.5),
                        AppColors.background,
                      ],
                    ),
                  ),
                ),

                // Background media: hình ảnh
                Positioned.fill(
                  child: Image.asset(
                    backgroundImageAsset,
                    fit: BoxFit.fill,
                    alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                    color: Colors.black.withValues(alpha: 0.16),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),

                // Hoạ tiết trang trí (nhẹ) để tăng thẩm mỹ
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _OrnamentPainter(
                        accentColor: accentColor,
                        isTop: isTop,
                      ),
                    ),
                  ),
                ),

                // Overlay mờ để text nổi bật (scrim theo hướng text)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: isTop ? Alignment.centerLeft : Alignment.centerRight,
                        end: isTop ? Alignment.centerRight : Alignment.centerLeft,
                        colors: [
                          Colors.black.withValues(alpha: 0.24),
                          Colors.black.withValues(alpha: 0.06),
                        ],
                      ),
                    ),
                  ),
                ),

                // Nội dung text + CTA
                Padding(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: contentCrossAxisAlignment,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: contentAlign,
                        child: _LocationCardHeader(
                          scale: scale,
                          chipLabel: chipLabel,
                          title: title,
                          subtitle: subtitle,
                          textAlign: textAlign,
                          crossAxisAlignment: contentCrossAxisAlignment,
                        ),
                      ),
                      Align(
                        alignment: contentAlign,
                        child: _LocationCtaPill(
                          scale: scale,
                          label: AppStrings.servicesLocationStartNow,
                          accentColor: accentColor,
                        ),
                      ),
                    ],
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

class _LocationCardHeader extends StatelessWidget {
  final double scale;
  final String chipLabel;
  final String title;
  final String subtitle;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  const _LocationCardHeader({
    required this.scale,
    required this.chipLabel,
    required this.title,
    required this.subtitle,
    required this.textAlign,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10 * scale,
            vertical: 4 * scale,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(100 * scale),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Text(
            chipLabel,
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        Text(
          title,
          textAlign: textAlign,
          style: AppTextStyles.tinos(
            fontSize: 22 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          subtitle,
          textAlign: textAlign,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _LocationCtaPill extends StatelessWidget {
  final double scale;
  final String label;
  final Color accentColor;

  const _LocationCtaPill({
    required this.scale,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          SizedBox(width: 6 * scale),
          Icon(
            Icons.arrow_forward_rounded,
            size: 18 * scale,
            color: accentColor,
          ),
        ],
      ),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  final Color accentColor;
  final bool isTop;

  const _OrnamentPainter({
    required this.accentColor,
    required this.isTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vòng tròn blur lớn
    final blurPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    final bigCenter = isTop
        ? Offset(size.width * 0.18, size.height * 0.22)
        : Offset(size.width * 0.82, size.height * 0.78);
    canvas.drawCircle(bigCenter, size.shortestSide * 0.28, blurPaint);

    final midPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final midCenter = isTop
        ? Offset(size.width * 0.88, size.height * 0.32)
        : Offset(size.width * 0.12, size.height * 0.62);
    canvas.drawCircle(midCenter, size.shortestSide * 0.18, midPaint);

    // Chấm bi nhỏ (pattern) ở phía đối diện text để cân bố cục
    final dotPaint = Paint()..color = AppColors.white.withValues(alpha: 0.22);
    final startX = isTop ? size.width * 0.62 : size.width * 0.08;
    final startY = isTop ? size.height * 0.58 : size.height * 0.10;
    final dx = size.width * 0.055;
    final dy = size.height * 0.06;
    final r = size.shortestSide * 0.008;

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        canvas.drawCircle(
          Offset(startX + col * dx, startY + row * dy),
          r,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor || oldDelegate.isTop != isTop;
  }
}