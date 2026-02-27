import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class ChatAppBar extends StatelessWidget {
  final String title;
  /// Thông tin khách hàng (cho staff) - Map chứa name, displayName, etc.
  final Map<String, dynamic>? customerInfo;
  /// null nếu không cho phép gửi yêu cầu hỗ trợ (staff mode).
  final VoidCallback? onSupport;
  final VoidCallback? onBack;

  const ChatAppBar({
    super.key,
    required this.title,
    this.customerInfo,
    required this.onSupport,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360 * scale;

          // Hiển thị customer name nếu có (cho staff), nếu không thì dùng title
          final displayTitle = customerInfo != null
              ? _getCustomerName(customerInfo!)
              : title;

          final titleWidget = Text(
            displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.tinos(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          );

          final subtitleWidget = Row(
            children: [
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6 * scale),
              Flexible(
                child: Text(
                  AppStrings.chatTypingHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          );

          return Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              Container(
                width: 42 * scale,
                height: 42 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4 * scale),
                  child: SvgPicture.asset(
                    AppAssets.appIconThird,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    SizedBox(height: 4 * scale),
                    subtitleWidget,
                  ],
                ),
              ),
              if (onSupport != null)
                (compact
                    ? IconButton(
                        onPressed: onSupport,
                        tooltip: AppStrings.chatRequestSupport,
                        icon: const Icon(Icons.support_agent,
                            color: AppColors.primary),
                      )
                    : TextButton.icon(
                        onPressed: onSupport,
                        icon: const Icon(Icons.support_agent,
                            color: AppColors.primary),
                        label: Text(
                          AppStrings.chatRequestSupport,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      )),
            ],
          );
        },
      ),
    );
  }

  String _getCustomerName(Map<String, dynamic> customerInfo) {
    // Thử các key phổ biến cho customer name
    return customerInfo['name']?.toString() ??
        customerInfo['displayName']?.toString() ??
        customerInfo['fullName']?.toString() ??
        customerInfo['customerName']?.toString() ??
        'Khách hàng';
  }
}

