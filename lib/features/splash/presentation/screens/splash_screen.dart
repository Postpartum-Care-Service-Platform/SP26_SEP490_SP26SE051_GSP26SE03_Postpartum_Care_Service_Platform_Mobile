import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateYAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    final introCurve = CurvedAnimation(parent: _introController, curve: Curves.easeInOut);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(introCurve);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(introCurve);

    _translateYAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 50),
    ]).animate(_floatingController);

    _rotateAnimation = Tween<double>(begin: -0.5, end: 0.5).animate(_floatingController);

    _highlightAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _introController.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a single scale factor for all responsive sizing.
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _translateYAnimation.value * scale),
                      child: Transform.rotate(
                        angle: _rotateAnimation.value * (math.pi / 180),
                        child: child,
                      ),
                    );
                  },
                  child: _buildIconContent(scale),
                ),
                const Spacer(flex: 2),
                Text(
                  AppStrings.loading,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16 * scale),
                LoadingIndicator(size: 24 * scale, strokeWidth: 3 * scale),
                SizedBox(height: 60 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContent(double scale) {
    return Container(
      padding: EdgeInsets.all(24 * scale),
      child: ShaderMask(
        shaderCallback: (bounds) {
          final p = _highlightAnimation.value;
          const band = 0.18;
          final s0 = (p - band).clamp(0.0, 1.0);
          final s1 = p.clamp(0.0, 1.0);
          final s2 = (p + band).clamp(0.0, 1.0);
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0x00FFFFFF),
              Color(0x33FFFFFF), // highlight
              Color(0x00FFFFFF),
            ],
            stops: [s0, s1, s2],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(AppAssets.appIconFirst, width: 80 * scale, height: 80 * scale),
                SizedBox(width: 16 * scale),
                SvgPicture.asset(AppAssets.appIcon, width: 80 * scale, height: 80 * scale),
                SizedBox(width: 16 * scale),
                SvgPicture.asset(AppAssets.appIconSecond, width: 80 * scale, height: 80 * scale),
              ],
            ),
            SizedBox(height: 32 * scale),
            Text(
              AppStrings.appName,
              style: AppTextStyles.tinos(
                fontSize: 40 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              AppStrings.tagline,
              style: AppTextStyles.tinos(
                fontSize: 16 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}