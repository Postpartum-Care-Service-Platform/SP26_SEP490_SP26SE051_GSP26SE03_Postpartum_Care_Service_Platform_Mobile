import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_text_styles.dart';

import '../../domain/entities/staff_feedback_entity.dart';
import '../bloc/staff_feedback_bloc.dart';
import '../bloc/staff_feedback_event.dart';
import '../bloc/staff_feedback_state.dart';

class StaffFeedbackScreen extends StatefulWidget {
  const StaffFeedbackScreen({super.key});

  @override
  State<StaffFeedbackScreen> createState() => _StaffFeedbackScreenState();
}

class _StaffFeedbackScreenState extends State<StaffFeedbackScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffFeedbackBloc>().add(FetchStaffFeedbacksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Đánh giá & Phản hồi',
          style: AppTextStyles.arimo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<StaffFeedbackBloc, StaffFeedbackState>(
        builder: (context, state) {
          if (state is StaffFeedbackLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is StaffFeedbackLoaded) {
            return _buildContent(context, state.feedbacks);
          } else if (state is StaffFeedbackError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: AppTextStyles.arimo(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTextStyles.arimo(fontSize: 14, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {
                      context.read<StaffFeedbackBloc>().add(FetchStaffFeedbacksEvent());
                    },
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<StaffFeedbackEntity> feedbacks) {
    if (feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: AppColors.third.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Chưa có phản hồi nào',
              style: AppTextStyles.arimo(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<StaffFeedbackBloc>().add(FetchStaffFeedbacksEvent());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildDataVisualization(feedbacks),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildFeedbackCard(feedbacks[index]);
                },
                childCount: feedbacks.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataVisualization(List<StaffFeedbackEntity> feedbacks) {
    // Calculate average rating
    double totalRating = 0;
    int validRatingCount = 0;
    
    // Calculate distribution
    Map<int, int> ratingDist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var fb in feedbacks) {
      if (fb.rating != null && fb.rating! > 0) {
        totalRating += fb.rating!;
        validRatingCount++;
        
        int r = fb.rating!;
        if (r > 5) r = 5;
        if (ratingDist.containsKey(r)) {
          ratingDist[r] = ratingDist[r]! + 1;
        }
      }
    }

    double averageRating = validRatingCount > 0 ? (totalRating / validRatingCount) : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan đánh giá',
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Average Score Column
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: AppTextStyles.arimo(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.round() ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFB800),
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$validRatingCount đánh giá',
                    style: AppTextStyles.arimo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Distribution Column
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((rating) {
                    final count = ratingDist[rating] ?? 0;
                    final ratio = validRatingCount > 0 ? count / validRatingCount : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: AppTextStyles.arimo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Color(0xFFFFB800), size: 12),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: AppColors.third.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getColorForRating(rating),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForRating(int rating) {
    switch (rating) {
      case 5:
        return const Color(0xFF4CAF50);
      case 4:
        return const Color(0xFF8BC34A);
      case 3:
        return const Color(0xFFFFC107);
      case 2:
        return const Color(0xFFFF9800);
      case 1:
      default:
        return const Color(0xFFF44336);
    }
  }

  Widget _buildFeedbackCard(StaffFeedbackEntity feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  feedback.customerName.isNotEmpty ? feedback.customerName[0].toUpperCase() : '?',
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.customerName.isNotEmpty ? feedback.customerName : 'Khách hàng',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(feedback.createdAt.toLocal()),
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (feedback.rating != null && feedback.rating! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        feedback.rating.toString(),
                        style: AppTextStyles.arimo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF57F17),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (feedback.title != null && feedback.title!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              feedback.title!,
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (feedback.content != null && feedback.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedback.content!,
              style: AppTextStyles.arimo(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
          if (feedback.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: feedback.images.length,
                itemBuilder: (context, idx) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(feedback.images[idx]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (feedback.bookingId != null)
                _buildTag('Booking #${feedback.bookingId}', Icons.receipt_long, AppColors.primary),
              if (feedback.feedbackTypeName.isNotEmpty)
                _buildTag(feedback.feedbackTypeName, Icons.label_outline, const Color(0xFF2196F3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
