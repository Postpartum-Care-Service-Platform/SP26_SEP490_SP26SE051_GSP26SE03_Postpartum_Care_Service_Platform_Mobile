import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

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
    final scale = AppResponsive.scaleFactor(context);

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
                      assetSvg: AppAssets.family,
                      showVideoBackground: true,
                      onTap: () => onLocationSelected(ServiceLocationType.center),
                    ),
                    _LocationHalfCard(
                      key: const ValueKey('home_location_card'),
                      isTop: false,
                      title: AppStrings.servicesLocationHomeTitle,
                      subtitle: AppStrings.servicesLocationHomeSubtitle,
                      chipLabel: AppStrings.servicesLocationHomeChip,
                      accentColor: AppColors.packagePro,
                      assetSvg: AppAssets.helper,
                      showVideoBackground: false,
                      onTap: () => onLocationSelected(ServiceLocationType.home),
                    ),
                  ],
                ),

                // Đường kẻ chéo chia đôi content
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _DiagonalDividerPainter(scale: scale),
                  ),
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
  final String assetSvg;
  final bool showVideoBackground;
  final VoidCallback onTap;

  const _LocationHalfCard({
    super.key,
    required this.isTop,
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.accentColor,
    required this.assetSvg,
    required this.showVideoBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24 * scale),
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

                // Background media: video cho ô trên, hình minh hoạ cho ô dưới
                Positioned.fill(
                  child: showVideoBackground
                      ? const _CenterVideoBackground()
                      : Opacity(
                          opacity: 0.15,
                          child: SvgPicture.asset(
                            assetSvg,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),

                // Overlay mờ để text nổi bật
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                        end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                // Nội dung text + CTA
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    isTop ? 72 * scale : 24 * scale,
                    20 * scale,
                    isTop ? 24 * scale : 72 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isTop ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            isTop ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * scale,
                              vertical: 4 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(100 * scale),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              chipLabel,
                              style: AppTextStyles.arimo(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          Text(
                            title,
                            textAlign: isTop ? TextAlign.left : TextAlign.right,
                            style: AppTextStyles.tinos(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6 * scale),
                          Text(
                            subtitle,
                            textAlign: isTop ? TextAlign.left : TextAlign.right,
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * scale,
                          vertical: 8 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100 * scale),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.servicesLocationStartNow,
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

class _DiagonalDividerPainter extends CustomPainter {
  final double scale;

  _DiagonalDividerPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 2 * scale
      ..style = PaintingStyle.stroke;

    // Đường kẻ chéo từ góc phải trên xuống góc trái dưới
    final start = Offset(size.width * 0.9, 0);
    final end = Offset(0, size.height * 0.9);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Video nền cho ô "Nghỉ dưỡng tại trung tâm"
class _CenterVideoBackground extends StatefulWidget {
  const _CenterVideoBackground();

  @override
  State<_CenterVideoBackground> createState() => _CenterVideoBackgroundState();
}

class _CenterVideoBackgroundState extends State<_CenterVideoBackground> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(AppAssets.servicesCenterResortVideo),
    )
      ..setLooping(true)
      ..setVolume(0);

    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.play();
      setState(() {
        _initialized = true;
      });
    }).catchError((_) {
      // Nếu load video lỗi thì giữ nguyên background gradient
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || !_controller.value.isInitialized) {
      // Fallback: không vẽ gì thêm, chỉ dùng gradient phía dưới
      return const SizedBox.expand();
    }

    final size = _controller.value.size;
    if (size.isEmpty) {
      return const SizedBox.expand();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

