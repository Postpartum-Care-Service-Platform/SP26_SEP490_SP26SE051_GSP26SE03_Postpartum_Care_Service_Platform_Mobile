import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/cloudinary_utils.dart';
import '../constants/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      if (errorBuilder != null) {
        return errorBuilder!(context, Exception('Empty URL'), StackTrace.current);
      }
      return _buildErrorWidget();
    }

    int? cacheWidth;
    if (width != null && !width!.isInfinite && !width!.isNaN) {
      cacheWidth = (width! * 2).toInt();
    }
    
    int? cacheHeight;
    if (height != null && !height!.isInfinite && !height!.isNaN) {
      cacheHeight = (height! * 2).toInt();
    }
    
    if (cacheWidth == null && cacheHeight == null) {
      cacheWidth = 500;
      cacheHeight = 500;
    }

    final optimizedUrl = CloudinaryUtils.getOptimizedUrl(
      url, 
      width: cacheWidth, 
      height: cacheHeight
    );

    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: AppColors.primary.withValues(alpha: 0.1),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24, 
          height: 24, 
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
        )
      ),
      errorWidget: (context, url, error) {
        if (errorBuilder != null) {
          return errorBuilder!(context, error, StackTrace.current);
        }
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.grey),
      ),
    );
  }
}
