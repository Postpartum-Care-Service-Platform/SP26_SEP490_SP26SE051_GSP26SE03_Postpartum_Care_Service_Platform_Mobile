import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_responsive.dart';
import '../utils/cloudinary_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Reusable avatar widget with support for image URL and fallback
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? displayName;
  final double size;
  final bool showVerifiedBadge;
  final bool isVerified;
  final Color? backgroundColor;
  final double borderWidth;
  final Color? borderColor;
  final IconData? fallbackIcon;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.displayName,
    this.size = 48,
    this.showVerifiedBadge = false,
    this.isVerified = false,
    this.backgroundColor,
    this.borderWidth = 0,
    this.borderColor,
    this.fallbackIcon,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final scaledSize = size * scale;
    final scaledBorderWidth = borderWidth * scale;

    final bool isLocalFile = imageUrl != null && imageUrl!.startsWith('file:///');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: scaledSize,
          height: scaledSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
            border: scaledBorderWidth > 0
                ? Border.all(
                    color: borderColor ?? AppColors.white,
                    width: scaledBorderWidth,
                  )
                : null,
            boxShadow: scaledBorderWidth > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? (isLocalFile
                    ? Image.file(
                        File(Uri.parse(imageUrl!).toFilePath()),
                        width: scaledSize,
                        height: scaledSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialsWidget(displayName, scaledSize, scale),
                      )
                    : CachedNetworkImage(
                        imageUrl: CloudinaryUtils.getOptimizedUrl(
                          imageUrl!,
                          width: scaledSize.toInt(),
                          height: scaledSize.toInt(),
                        ),
                        width: scaledSize,
                        height: scaledSize,
                        memCacheWidth: scaledSize.toInt() * 2,
                        memCacheHeight: scaledSize.toInt() * 2,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return _buildInitialsWidget(displayName, scaledSize, scale);
                        },
                        placeholder: (context, url) {
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          );
                        },
                      ))
                : _buildInitialsWidget(displayName, scaledSize, scale),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsWidget(String? name, double size, double scale) {
    if (fallbackIcon != null && (name == null || name.isEmpty || name == '?')) {
      return Center(
        child: Icon(
          fallbackIcon,
          size: size * 0.5,
          color: AppColors.primary,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Text(
        _getInitials(name ?? '?'),
        style: AppTextStyles.tinos(
          fontSize: (size * 0.4),
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
