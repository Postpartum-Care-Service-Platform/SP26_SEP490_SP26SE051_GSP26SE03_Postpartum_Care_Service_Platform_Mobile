import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/feedback_bloc.dart';
import '../bloc/feedback_event.dart';
import '../bloc/feedback_state.dart';
import '../widgets/feedback_card.dart';
import '../widgets/create_feedback_sheet.dart';

/// Feedback Screen
/// Displays user's feedbacks and allows creating new feedback
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  void initState() {
    super.initState();
    // Load feedbacks and types on init
    context.read<FeedbackBloc>()
      ..add(const FeedbackTypesLoadRequested())
      ..add(const MyFeedbacksLoadRequested());
  }

  void _handleCreateFeedback() {
    final state = context.read<FeedbackBloc>().state;
    if (state is MyFeedbacksLoaded) {
      CreateFeedbackSheet.show(context, state.types);
    } else if (state is FeedbackTypesLoaded) {
      CreateFeedbackSheet.show(context, state.types);
    } else {
      // Load types first
      context.read<FeedbackBloc>().add(const FeedbackTypesLoadRequested());
      // Wait a bit then show sheet
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final newState = context.read<FeedbackBloc>().state;
        if (newState is FeedbackTypesLoaded) {
          CreateFeedbackSheet.show(context, newState.types);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackError) {
          AppLoading.hide(context);
          AppToast.showError(context, message: state.message);
        } else if (state is MyFeedbacksLoaded) {
          // Hide loading when feedbacks are loaded (after creation or initial load)
          AppLoading.hide(context);
        } else if (state is FeedbackCreated) {
          // Feedback created, feedbacks will be reloaded automatically by bloc
          // Loading will be hidden when MyFeedbacksLoaded is emitted
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: AppStrings.feedbackTitle,
          showBackButton: true,
          centerTitle: true,
        ),
        body: BlocBuilder<FeedbackBloc, FeedbackState>(
          builder: (context, state) {
            if (state is FeedbackLoading) {
              return Center(
                child: AppLoadingIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is MyFeedbacksLoaded) {
              if (state.feedbacks.isEmpty) {
                return _buildEmptyState(context, scale);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FeedbackBloc>().add(
                        const MyFeedbacksRefreshRequested(),
                      );
                },
                color: AppColors.primary,
                child: ListView(
                  padding: EdgeInsets.all(20 * scale),
                  children: [
                    ...state.feedbacks.map((feedback) {
                      final type = state.types.firstWhere(
                        (t) => t.id == feedback.feedbackTypeId,
                        orElse: () => state.types.first,
                      );
                      return FeedbackCard(
                        feedback: feedback,
                        feedbackType: type,
                      );
                    }),
                  ],
                ),
              );
            }

            if (state is FeedbackError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64 * scale,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24 * scale),
                    AppWidgets.primaryButton(
                      text: AppStrings.retry,
                      onPressed: () {
                        context.read<FeedbackBloc>().add(
                              const MyFeedbacksLoadRequested(),
                            );
                      },
                      width: 200,
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _handleCreateFeedback,
          backgroundColor: AppColors.primary,
          child: SvgPicture.asset(
            AppAssets.pencilFeedback,
            width: 24 * scale,
            height: 24 * scale,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    double scale,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 44 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              AppStrings.feedbackNoFeedback,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8 * scale),
            Text(
              AppStrings.feedbackShareExperience,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
