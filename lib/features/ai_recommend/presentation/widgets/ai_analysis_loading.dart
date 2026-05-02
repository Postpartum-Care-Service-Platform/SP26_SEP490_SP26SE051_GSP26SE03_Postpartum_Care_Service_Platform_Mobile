import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Animated loading overlay that simulates AI processing steps
class AiAnalysisLoading extends StatefulWidget {
  const AiAnalysisLoading({super.key});

  @override
  State<AiAnalysisLoading> createState() => _AiAnalysisLoadingState();
}

class _AiAnalysisLoadingState extends State<AiAnalysisLoading>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  Timer? _timer;

  late AnimationController _fadeController;
  late AnimationController _dotController;

  static const _steps = [
    _AnalysisStep(
      icon: Icons.health_and_safety_rounded,
      text: 'Đang phân tích hồ sơ sức khoẻ...',
      color: Color(0xFFFFB74D), // Light Orange
    ),
    _AnalysisStep(
      icon: Icons.compare_arrows_rounded,
      text: 'Đang so sánh các gói dịch vụ...',
      color: Color(0xFFFFA726), // Medium Orange
    ),
    _AnalysisStep(
      icon: Icons.psychology_rounded,
      text: 'AI đang đánh giá mức độ phù hợp...',
      color: Color(0xFFFF9800), // Primary Orange
    ),
    _AnalysisStep(
      icon: Icons.auto_awesome,
      text: 'Đang tổng hợp kết quả tư vấn...',
      color: Color(0xFFE65100), // Deep Orange
    ),
  ];

  double _progress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Progress timer: 45 seconds total
    const totalDuration = Duration(seconds: 45);
    const updateInterval = Duration(milliseconds: 100);
    final totalTicks = totalDuration.inMilliseconds / updateInterval.inMilliseconds;
    
    _progressTimer = Timer.periodic(updateInterval, (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 1.0 / totalTicks;
        if (_progress > 1.0) _progress = 1.0;
        
        // Calculate step based on progress
        int newStep = (_progress * _steps.length).floor();
        if (newStep >= _steps.length) newStep = _steps.length - 1;
        
        if (newStep != _currentStep) {
          _fadeController.reverse().then((_) {
            if (mounted) {
              setState(() => _currentStep = newStep);
              _fadeController.forward();
            }
          });
        }
      });
      
      if (_progress >= 1.0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _fadeController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final step = _steps[_currentStep];

    return PopScope(
      canPop: false, // Prevent closing by back button during analysis
      child: Container(
        padding: EdgeInsets.fromLTRB(24 * scale, 16 * scale, 24 * scale, 24 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28 * scale)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle - but non-functional since enableDrag is false
            Container(
              width: 40 * scale,
              height: 4 * scale,
              margin: EdgeInsets.only(bottom: 32 * scale),
              decoration: BoxDecoration(
                color: AppColors.borderLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),

          // AI Brain animation
          _buildBrainAnimation(scale),

          SizedBox(height: 32 * scale),

          // Current step with fade animation
          FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(14 * scale),
                  decoration: BoxDecoration(
                    color: step.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    color: step.color,
                    size: 28 * scale,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Text(
                  step.text,
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 28 * scale),

          // Step progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (i) {
              final isActive = i <= _currentStep;
              final isCurrent = i == _currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4 * scale),
                width: isCurrent ? 24 * scale : 6 * scale,
                height: 6 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4 * scale),
                  color: isActive
                      ? _steps[i].color
                      : AppColors.borderLight.withValues(alpha: 0.5),
                ),
              );
            }),
          ),

          SizedBox(height: 24 * scale),

          // Linear progress bar for overall 45s progress
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32 * scale),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10 * scale),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6 * scale,
                    backgroundColor: AppColors.borderLight.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24 * scale),

          // Subtitle
          Text(
            'Vui lòng chờ trong giây lát...',
            style: AppTextStyles.arimo(
              fontSize: 12.5 * scale,
              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8 * scale),
        ],
      ),
    ),
  );
}

  Widget _buildBrainAnimation(double scale) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        return SizedBox(
          width: 80 * scale,
          height: 80 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Transform.scale(
                scale: 1.0 + (_dotController.value * 0.3),
                child: Container(
                  width: 80 * scale,
                  height: 80 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: 0.3 * (1 - _dotController.value),
                      ),
                      width: 2 * scale,
                    ),
                  ),
                ),
              ),
              // Inner circle
              Container(
                width: 60 * scale,
                height: 60 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF8C00),
                      const Color(0xFFE85D04),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16 * scale,
                      spreadRadius: 2 * scale,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 30 * scale,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalysisStep {
  final IconData icon;
  final String text;
  final Color color;

  const _AnalysisStep({
    required this.icon,
    required this.text,
    required this.color,
  });
}
