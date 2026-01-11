import 'package:flutter/material.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/time_utils.dart';

class HomeHeader extends StatelessWidget {
  final String? userName;
  final bool isLoading;

  const HomeHeader({
    super.key,
    this.userName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TimeUtils.getGreeting(),
                style: AppTextStyles.arimo(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              if (isLoading)
                _UsernameSkeleton(scale: scale)
              else
                Text(
                  userName ?? 'Mom',
                  style: AppTextStyles.tinos(fontSize: 24, fontWeight: FontWeight.bold),
                ),
            ],
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
