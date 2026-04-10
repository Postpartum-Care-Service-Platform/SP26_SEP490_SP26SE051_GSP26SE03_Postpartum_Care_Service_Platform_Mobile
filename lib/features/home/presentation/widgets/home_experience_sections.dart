import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// 1) Welcome information section with intro text and small icons row.
class HomeWelcomeSection extends StatelessWidget {
  const HomeWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeWelcomeSubtitle,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 20 * scale),
        Text(
          AppStrings.homeWelcomeDescription,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ).copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// 2) Service / facility / cuisine image collage section.
class HomeServiceGallerySection extends StatelessWidget {
  const HomeServiceGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeServiceGalleryTitle,
          style: AppTextStyles.tinos(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          AppStrings.homeServiceGallerySubtitle,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16 * scale),
        ClipRRect(
          borderRadius: BorderRadius.circular(18 * scale),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              AppAssets.homeServiceMain,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    AppAssets.homeServiceCuisine,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    AppAssets.homeServiceCare,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            AppStrings.homeServiceGalleryNote,
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

/// 3) Large hero banner "The Joyful Experience".
class HomeExperienceBanner extends StatelessWidget {
  const HomeExperienceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24 * scale),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              AppAssets.homeExperienceBanner,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 20 * scale,
            right: 20 * scale,
            top: 24 * scale,
            bottom: 24 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.homeExperienceTitle,
                  style: AppTextStyles.tinos(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  AppStrings.homeExperienceSubtitle,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 10 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999 * scale),
                  ),
                  child: Text(
                    AppStrings.homeExperienceCta,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Home testimonial model from API.
class _HomeTestimonial {
  final String fullName;
  final String content;
  final int rating;
  final String avatar;

  const _HomeTestimonial({
    required this.fullName,
    required this.content,
    required this.rating,
    required this.avatar,
  });

  factory _HomeTestimonial.fromJson(Map<String, dynamic> json) {
    return _HomeTestimonial(
      fullName: (json['fullName'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse((json['rating'] ?? '0').toString()) ?? 0,
      avatar: (json['avatar'] ?? '').toString(),
    );
  }
}

/// 4) Banner with feedback slide (mock data, no API yet).
class HomeTestimonialBanner extends StatefulWidget {
  const HomeTestimonialBanner({super.key});

  @override
  State<HomeTestimonialBanner> createState() => _HomeTestimonialBannerState();
}

class _HomeTestimonialBannerState extends State<HomeTestimonialBanner> {
  static const int _initialTestimonialPage = 1000000;

  late final PageController _pageController;
  List<_HomeTestimonial> _testimonials = const [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.7,
      initialPage: _initialTestimonialPage,
    );
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoints.feedbackContent);
      final data = response.data;

      final parsed = data is List
          ? data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .map(_HomeTestimonial.fromJson)
              .where((item) => item.fullName.trim().isNotEmpty)
              .toList()
          : <_HomeTestimonial>[];

      if (!mounted) return;
      setState(() {
        _testimonials = parsed;
        _isLoading = false;
      });

      _startAutoSlideIfNeeded();
    } on DioException {
      if (!mounted) return;
      setState(() {
        _testimonials = const [];
        _isLoading = false;
      });
    }
  }

  void _startAutoSlideIfNeeded() {
    _timer?.cancel();
    if (_testimonials.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!_pageController.hasClients || _testimonials.isEmpty) return;
      final nextPage = ((_pageController.page ?? _initialTestimonialPage) + 1)
          .round();
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  List<TextSpan> _buildFormattedSpans(String text, TextStyle baseStyle) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return [TextSpan(text: '', style: baseStyle)];

    final spans = <TextSpan>[];
    final pattern = RegExp(
      r'(\*\*\*[^*]+\*\*\*|___[^_]+___|\*\*[^*]+\*\*|__[^_]+__|\*[^*]+\*)',
    );

    var currentIndex = 0;
    for (final match in pattern.allMatches(normalized)) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: normalized.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final token = match.group(0) ?? '';
      if (token.startsWith('***') && token.endsWith('***')) {
        final content = token.substring(3, token.length - 3);
        spans.add(
          TextSpan(
            text: content,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else if (token.startsWith('___') && token.endsWith('___')) {
        final content = token.substring(3, token.length - 3);
        spans.add(
          TextSpan(
            text: content,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      } else if (token.startsWith('**') && token.endsWith('**')) {
        final content = token.substring(2, token.length - 2);
        spans.add(
          TextSpan(
            text: content,
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if (token.startsWith('__') && token.endsWith('__')) {
        final content = token.substring(2, token.length - 2);
        spans.add(
          TextSpan(
            text: content,
            style: baseStyle.copyWith(decoration: TextDecoration.underline),
          ),
        );
      } else if (token.startsWith('*') && token.endsWith('*')) {
        final content = token.substring(1, token.length - 1);
        spans.add(
          TextSpan(
            text: content,
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else {
        spans.add(TextSpan(text: token, style: baseStyle));
      }

      currentIndex = match.end;
    }

    if (currentIndex < normalized.length) {
      spans.add(
        TextSpan(
          text: normalized.substring(currentIndex),
          style: baseStyle,
        ),
      );
    }

    return spans;
  }

  Widget _buildRatingStars(double scale, int rating) {
    final normalizedRating = rating.clamp(0, 5);
    return Row(
      children: List.generate(5, (index) {
        final filled = index < normalizedRating;
        return Padding(
          padding: EdgeInsets.only(right: 2 * scale),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 14 * scale,
            color: filled ? AppColors.primary : AppColors.textSecondary,
          ),
        );
      }),
    );
  }

  void _showFullContent(_HomeTestimonial item) {
    final scale = AppResponsive.scaleFactor(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              18 * scale,
              20 * scale,
              (20 * scale) + bottomInset,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fullName,
                    style: AppTextStyles.tinos(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  _buildRatingStars(scale, item.rating),
                  SizedBox(height: 12 * scale),
                  Text.rich(
                    TextSpan(
                      children: _buildFormattedSpans(
                        item.content,
                        AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textPrimary,
                        ).copyWith(height: 1.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeTestimonialTitle,
          style: AppTextStyles.tinos(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12 * scale),
        SizedBox(
          height: 240 * scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18 * scale),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.homeTestimonialBackground,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  )
                else if (_testimonials.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                      child: Text(
                        'Chưa có câu chuyện nào được gửi gắm.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  )
                else
                  PageView.builder(
                    controller: _pageController,
                    padEnds: true,
                    itemBuilder: (context, index) {
                      final item = _testimonials[index % _testimonials.length];
                      final fullName = item.fullName.trim();
                      final initials = fullName.isNotEmpty
                          ? fullName.characters.first.toUpperCase()
                          : '?';
                      final normalizedContent = item.content
                          .replaceAll(RegExp(r'\s+'), ' ')
                          .trim();

                      return Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => _showFullContent(item),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 10 * scale,
                              vertical: 24 * scale,
                            ),
                            padding: EdgeInsets.all(20 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16 * scale),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 18 * scale,
                                  offset: Offset(0, 6 * scale),
                                ),
                              ],
                            ),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '"',
                                        style: AppTextStyles.arimo(
                                          fontSize: 13 * scale,
                                          color: AppColors.textPrimary,
                                        ).copyWith(height: 1.5),
                                      ),
                                      ..._buildFormattedSpans(
                                        normalizedContent,
                                        AppTextStyles.arimo(
                                          fontSize: 13 * scale,
                                          color: AppColors.textPrimary,
                                        ).copyWith(height: 1.5),
                                      ),
                                      TextSpan(
                                        text: '"',
                                        style: AppTextStyles.arimo(
                                          fontSize: 13 * scale,
                                          color: AppColors.textPrimary,
                                        ).copyWith(height: 1.5),
                                      ),
                                    ],
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18 * scale,
                                    backgroundColor: AppColors.primary,
                                    backgroundImage: item.avatar.trim().isNotEmpty
                                        ? NetworkImage(item.avatar)
                                        : null,
                                    child: item.avatar.trim().isEmpty
                                        ? Text(
                                            initials,
                                            style: AppTextStyles.tinos(
                                              fontSize: 16 * scale,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 10 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fullName,
                                          style: AppTextStyles.tinos(
                                            fontSize: 14 * scale,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        _buildRatingStars(scale, item.rating),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 5) Love-wall style continuous slider with feedback images.
class HomeLoveWallSection extends StatefulWidget {
  const HomeLoveWallSection({super.key});

  @override
  State<HomeLoveWallSection> createState() => _HomeLoveWallSectionState();
}

class _HomeLoveWallSectionState extends State<HomeLoveWallSection> {
  static const int _initialLoopPage = 1000000;

  late final PageController _pageController;
  List<String> _imagePaths = const [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: _initialLoopPage,
    );
    _loadLoveWallImages();
  }

  Future<void> _loadLoveWallImages() async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoints.feedbackImages);
      final data = response.data;

      final imageUrls = <String>[];
      if (data is List) {
        for (final item in data) {
          if (item is String) {
            try {
              final decoded = jsonDecode(item);
              if (decoded is List) {
                for (final url in decoded) {
                  final parsedUrl = (url ?? '').toString().trim();
                  if (parsedUrl.isNotEmpty) {
                    imageUrls.add(parsedUrl);
                  }
                }
              }
            } catch (_) {
              // Skip invalid JSON item
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _imagePaths = imageUrls;
        _isLoading = false;
      });

      if (_imagePaths.isNotEmpty) {
        _startAutoSlideIfNeeded();
      }
    } on DioException {
      if (!mounted) return;
      setState(() {
        _imagePaths = const [];
        _isLoading = false;
      });
    }
  }

  void _startAutoSlideIfNeeded() {
    _timer?.cancel();
    if (_imagePaths.length <= 1) return;

    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_pageController.hasClients || _imagePaths.isEmpty) return;

      final position = _pageController.position;
      if (!position.hasPixels) return;

      final nextOffset = position.pixels + 0.45;
      _pageController.jumpTo(nextOffset);
    });
  }

  void _showImageDetail(String imageUrl) {
    final scale = AppResponsive.scaleFactor(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 24 * scale),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, color: AppColors.white),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8 * scale,
                right: 8 * scale,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close, color: AppColors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeLoveWallTitle,
          style: AppTextStyles.tinos(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          AppStrings.homeLoveWallSubtitle,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16 * scale),
        SizedBox(
          height: 180 * scale,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _imagePaths.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có hình ảnh được gửi gắm.',
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      padEnds: false,
                      itemBuilder: (context, index) {
                        final imageIndex = index % _imagePaths.length;
                        final imageUrl = _imagePaths[imageIndex];

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                          child: GestureDetector(
                            onTap: () => _showImageDetail(imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18 * scale),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.background,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

