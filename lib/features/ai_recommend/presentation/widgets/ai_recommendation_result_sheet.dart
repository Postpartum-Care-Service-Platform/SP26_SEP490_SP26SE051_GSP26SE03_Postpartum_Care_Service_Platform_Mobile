import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/ai_recommendation_entity.dart';

class AiRecommendationResultSheet extends StatefulWidget {
  final AiRecommendation recommendation;
  final void Function(int packageId) onSelectPackage;

  const AiRecommendationResultSheet({
    super.key,
    required this.recommendation,
    required this.onSelectPackage,
  });

  @override
  State<AiRecommendationResultSheet> createState() =>
      _AiRecommendationResultSheetState();
}

class _AiRecommendationResultSheetState
    extends State<AiRecommendationResultSheet> with TickerProviderStateMixin {
  int? _expandedIndex;
  final Map<int, String> _typedNarratives = {};
  final Map<int, bool> _isTyping = {};

  @override
  void initState() {
    super.initState();
    // Start typing for the first (top) package automatically
    if (widget.recommendation.packages.isNotEmpty) {
      _expandedIndex = 0;
      _startTyping(0, widget.recommendation.packages[0].narrative);
    }
  }

  void _startTyping(int index, String fullText) {
    if (_isTyping[index] == true) return;
    
    _isTyping[index] = true;
    _typedNarratives[index] = "";
    
    int charIndex = 0;
    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (charIndex < fullText.length) {
        setState(() {
          _typedNarratives[index] = fullText.substring(0, charIndex + 1);
        });
        charIndex++;
      } else {
        _isTyping[index] = false;
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final packages = widget.recommendation.packages;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28 * scale)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.only(top: 8 * scale, bottom: 4 * scale),
            child: Container(
              width: 40 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),
          ),

          // Header
          _buildHeader(scale),

          // Package list
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  16 * scale, 0, 16 * scale, 16 * scale),
              shrinkWrap: true,
              itemCount: packages.length,
              itemBuilder: (context, index) {
                return _buildPackageCard(
                    scale, packages[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20 * scale, 12 * scale, 20 * scale, 16 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8C00), Color(0xFFE85D04)],
              ),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22 * scale,
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kết quả tư vấn AI',
                  style: AppTextStyles.tinos(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'Xếp hạng theo mức độ phù hợp',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, size: 22 * scale),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
      double scale, AiRecommendedPackage pkg, int index) {
    final isExpanded = _expandedIndex == index;
    final isTop = index == 0;
    final scoreColor = _getScoreColor(pkg.matchScore);

    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18 * scale),
          border: Border.all(
            color: isTop
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.borderLight,
            width: isTop ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isTop ? AppColors.primary : Colors.black)
                  .withValues(alpha: isTop ? 0.08 : 0.04),
              blurRadius: 12 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            InkWell(
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? null : index;
                  if (_expandedIndex != null && _typedNarratives[index] == null) {
                    _startTyping(index, pkg.narrative);
                  }
                });
              },
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18 * scale),
                bottom: isExpanded
                    ? Radius.zero
                    : Radius.circular(18 * scale),
              ),
              child: Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Row(
                  children: [
                    // Rank badge
                    if (isTop)
                      Container(
                        width: 32 * scale,
                        height: 32 * scale,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFFA000)
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8 * scale,
                            ),
                          ],
                        ),
                        child: Icon(Icons.star_rounded,
                            color: Colors.white,
                            size: 18 * scale),
                      )
                    else
                      Container(
                        width: 32 * scale,
                        height: 32 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.borderLight),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                    SizedBox(width: 12 * scale),

                    // Package name
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            pkg.packageName,
                            style: AppTextStyles.tinos(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isTop) ...[
                            SizedBox(height: 2 * scale),
                            Text(
                              '⭐ Phù hợp nhất',
                              style: AppTextStyles.arimo(
                                fontSize: 11.5 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Score circle
                    _buildScoreCircle(
                        scale, pkg.matchScore, scoreColor),

                    SizedBox(width: 8 * scale),

                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 22 * scale,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (isExpanded) ...[
              Divider(
                  height: 1,
                  color: AppColors.borderLight,
                  indent: 16 * scale,
                  endIndent: 16 * scale),
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Narrative
                    Container(
                      padding: EdgeInsets.all(14 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius:
                            BorderRadius.circular(12 * scale),
                        border: Border.all(
                            color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded,
                              color: AppColors.primary,
                              size: 20 * scale),
                          SizedBox(width: 10 * scale),
                          Expanded(
                            child: Text(
                              _typedNarratives[index] ?? (isExpanded ? "" : pkg.narrative),
                              style: AppTextStyles.arimo(
                                fontSize: 13.5 * scale,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16 * scale),

                    // Pros
                    if (pkg.pros.isNotEmpty) ...[
                      _buildListSection(
                        scale,
                        title: 'Ưu điểm',
                        items: pkg.pros,
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF4CAF50),
                      ),
                      SizedBox(height: 12 * scale),
                    ],

                    // Cautions
                    if (pkg.cautions.isNotEmpty) ...[
                      _buildListSection(
                        scale,
                        title: 'Lưu ý',
                        items: pkg.cautions,
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFFF9800),
                      ),
                      SizedBox(height: 12 * scale),
                    ],

                    // Missing fit
                    if (pkg.missingFit.isNotEmpty) ...[
                      _buildListSection(
                        scale,
                        title: 'Chưa phù hợp',
                        items: pkg.missingFit,
                        icon: Icons.remove_circle_outline_rounded,
                        color: const Color(0xFFF44336),
                      ),
                      SizedBox(height: 12 * scale),
                    ],

                    // Select button
                    SizedBox(
                      width: double.infinity,
                      height: 46 * scale,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onSelectPackage(pkg.packageId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTop
                              ? AppColors.primary
                              : AppColors.white,
                          foregroundColor: isTop
                              ? Colors.white
                              : AppColors.primary,
                          elevation: isTop ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12 * scale),
                            side: isTop
                                ? BorderSide.none
                                : BorderSide(
                                    color: AppColors.primary),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18 * scale),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Chọn gói này',
                              style: AppTextStyles.arimo(
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(
      double scale, int score, Color color) {
    return SizedBox(
      width: 48 * scale,
      height: 48 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44 * scale,
            height: 44 * scale,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 3.5 * scale,
              backgroundColor:
                  AppColors.borderLight.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$score',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    double scale, {
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16 * scale),
            SizedBox(width: 6 * scale),
            Text(
              title,
              style: AppTextStyles.arimo(
                fontSize: 13.5 * scale,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(
                  left: 22 * scale, bottom: 6 * scale),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5 * scale,
                    height: 5 * scale,
                    margin: EdgeInsets.only(top: 7 * scale),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}
