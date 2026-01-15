import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/avatar_widget.dart';

class HomeHeader extends StatelessWidget {
  final String? userName;
  final String? avatarUrl;
  final bool isEmailVerified;
  final bool isLoading;

  const HomeHeader({
    super.key,
    this.userName,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Avatar
                AvatarWidget(
                  imageUrl: avatarUrl,
                  displayName: userName,
                  size: 48,
                  showVerifiedBadge: true,
                  isVerified: isEmailVerified,
                  borderWidth: 2,
                ),
                SizedBox(width: 12 * scale),
                // Greeting and name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        TimeUtils.getGreeting(),
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isLoading)
                        _UsernameSkeleton(scale: scale)
                      else
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName ?? 'User',
                                style: AppTextStyles.tinos(
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isEmailVerified) ...[
                              SizedBox(width: 6 * scale),
                              Icon(
                                Icons.verified,
                                size: 16 * scale,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.grey[800]),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}

class _UsernameSkeleton extends StatefulWidget {
  final double scale;

  const _UsernameSkeleton({required this.scale});

  @override
  State<_UsernameSkeleton> createState() => _UsernameSkeletonState();
}

class _UsernameSkeletonState extends State<_UsernameSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = 120.0 * widget.scale;
    final height = 28.0 * widget.scale;
    final borderRadius = 4.0 * widget.scale;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
