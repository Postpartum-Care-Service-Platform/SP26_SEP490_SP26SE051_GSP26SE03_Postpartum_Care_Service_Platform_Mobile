import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/di/injection_container.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../care_plan/domain/entities/care_plan_entity.dart';
import '../../../care_plan/presentation/bloc/care_plan_bloc.dart';
import '../../../care_plan/presentation/bloc/care_plan_event.dart';
import '../../../care_plan/presentation/bloc/care_plan_state.dart';

/// Bottom sheet hiển thị chi tiết gói dịch vụ khi user nhấn giữ
class PackageDetailBottomSheet extends StatefulWidget {
  final PackageEntity package;

  const PackageDetailBottomSheet({
    super.key,
    required this.package,
  });

  /// Show the bottom sheet
  static void show(
    BuildContext context, {
    required PackageEntity package,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => InjectionContainer.carePlanBloc
          ..add(CarePlanLoadRequested(package.id)),
        child: PackageDetailBottomSheet(package: package),
      ),
    );
  }

  @override
  State<PackageDetailBottomSheet> createState() =>
      _PackageDetailBottomSheetState();
}

class _PackageDetailBottomSheetState extends State<PackageDetailBottomSheet> {
  late PageController _pageController;
  int _currentDayIndex = 0;
  List<int> _availableDays = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }

    return '${buffer.toString()}${AppStrings.currencyUnit}';
  }

  List<int> _getAvailableDays(List<CarePlanEntity> carePlans) {
    final days = carePlans.map((e) => e.dayNo).toSet().toList()..sort();
    return days;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentDayIndex = index;
    });
  }

  void _onDaySelected(int dayNo) {
    final index = _availableDays.indexOf(dayNo);
    if (index != -1 && index != _currentDayIndex) {
      _pageController.jumpToPage(index);
      setState(() {
        _currentDayIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final pkg = widget.package;

    return Container(
      height: screenHeight * 0.88,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * scale),
          topRight: Radius.circular(20 * scale),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12 * scale),
            width: 40 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
          // Scrollable content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Package header image
                SliverToBoxAdapter(
                  child: _buildPackageHeader(context, pkg, scale),
                ),
                // Package info section
                SliverToBoxAdapter(
                  child: _buildPackageInfo(context, pkg, scale),
                ),
                // Divider
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: Divider(
                      color: AppColors.borderLight,
                      height: 1,
                    ),
                  ),
                ),
                // Care plan section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      20 * scale,
                      20 * scale,
                      12 * scale,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8 * scale),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 20 * scale,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.carePlanTitle,
                                style: AppTextStyles.tinos(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2 * scale),
                              Text(
                                'Hoạt động chăm sóc theo từng ngày',
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Day picker
                SliverToBoxAdapter(
                  child: BlocBuilder<CarePlanBloc, CarePlanState>(
                    builder: (context, state) {
                      if (state is CarePlanLoaded) {
                        final availableDays =
                            _getAvailableDays(state.carePlans);
                        if (availableDays.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_currentDayIndex >= availableDays.length) {
                            setState(() {
                              _currentDayIndex = 0;
                            });
                          }
                          if (_availableDays != availableDays) {
                            setState(() {
                              _availableDays = availableDays;
                            });
                          }
                        });

                        final selectedDayNo = availableDays.isNotEmpty &&
                                _currentDayIndex < availableDays.length
                            ? availableDays[_currentDayIndex]
                            : availableDays.isNotEmpty
                                ? availableDays[0]
                                : null;

                        return _DayNoPicker(
                          availableDays: availableDays,
                          selectedDayNo: selectedDayNo,
                          onDaySelected: _onDaySelected,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 12 * scale),
                ),
                // Activities timeline
                SliverFillRemaining(
                  child: BlocBuilder<CarePlanBloc, CarePlanState>(
                    builder: (context, state) {
                      if (state is CarePlanLoading) {
                        return const Center(
                          child: AppLoadingIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (state is CarePlanError) {
                        return Center(
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 20 * scale),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48 * scale,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  state.message,
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is CarePlanLoaded) {
                        final availableDays =
                            _getAvailableDays(state.carePlans);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_availableDays != availableDays) {
                            setState(() {
                              _availableDays = availableDays;
                              if (_currentDayIndex >= availableDays.length) {
                                _currentDayIndex = 0;
                              }
                            });
                          }
                        });

                        if (availableDays.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 48 * scale,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  AppStrings.noCarePlanDetails,
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: availableDays.length,
                          itemBuilder: (context, index) {
                            final dayNo = availableDays[index];
                            final dayActivities = state.carePlans
                                .where((cp) => cp.dayNo == dayNo)
                                .toList()
                              ..sort((a, b) {
                                final byOrder =
                                    a.sortOrder.compareTo(b.sortOrder);
                                if (byOrder != 0) return byOrder;
                                return a.startTime.compareTo(b.startTime);
                              });

                            return _ActivityListView(
                              dayNo: dayNo,
                              activities: dayActivities,
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Package image header
  Widget _buildPackageHeader(
      BuildContext context, PackageEntity pkg, double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20 * scale, 16 * scale, 20 * scale, 16 * scale),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16 * scale),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: pkg.imageUrl != null && pkg.imageUrl!.isNotEmpty
                  ? Image.network(
                      pkg.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(scale),
                    )
                  : _fallbackImage(scale),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16 * scale),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 10 * scale,
            right: 10 * scale,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(6 * scale),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20 * scale,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          // Package name & price overlay
          Positioned(
            left: 16 * scale,
            right: 16 * scale,
            bottom: 16 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pkg.packageName,
                  style: AppTextStyles.tinos(
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ).copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 6 * scale,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  _formatPrice(pkg.basePrice),
                  style: AppTextStyles.arimo(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          // Duration badge
          Positioned(
            top: 10 * scale,
            left: 10 * scale,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 5 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14 * scale,
                    color: AppColors.white,
                  ),
                  SizedBox(width: 4 * scale),
                  Text(
                    '${pkg.durationDays ?? '--'} ${AppStrings.days}',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Package info details
  Widget _buildPackageInfo(
      BuildContext context, PackageEntity pkg, double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20 * scale, 0, 20 * scale, 20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (pkg.description.isNotEmpty) ...[
            Text(
              pkg.description,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ).copyWith(height: 1.5),
            ),
            SizedBox(height: 16 * scale),
          ],
          // Info chips
          Wrap(
            spacing: 10 * scale,
            runSpacing: 10 * scale,
            children: [
              if (pkg.roomTypeName != null)
                _InfoChip(
                  icon: Icons.hotel_rounded,
                  label: pkg.roomTypeName!,
                  scale: scale,
                ),
              if (pkg.packageTypeName != null)
                _InfoChip(
                  icon: Icons.local_hospital_rounded,
                  label: pkg.packageTypeName!,
                  scale: scale,
                ),
              if (pkg.totalRooms != null)
                _InfoChip(
                  icon: Icons.meeting_room_rounded,
                  label:
                      'Còn ${pkg.availableRooms ?? 0}/${pkg.totalRooms} phòng',
                  scale: scale,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage(double scale) {
    return Container(
      color: AppColors.borderLight,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 34 * scale,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double scale;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16 * scale,
            color: AppColors.primary,
          ),
          SizedBox(width: 6 * scale),
          Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Day number picker
class _DayNoPicker extends StatelessWidget {
  final List<int> availableDays;
  final int? selectedDayNo;
  final Function(int) onDaySelected;

  const _DayNoPicker({
    required this.availableDays,
    this.selectedDayNo,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      height: 50 * scale,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableDays.length,
        itemBuilder: (context, index) {
          final dayNo = availableDays[index];
          final isSelected = dayNo == selectedDayNo;

          return GestureDetector(
            onTap: () => onDaySelected(dayNo),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 10 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.borderLight,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${AppStrings.day} $dayNo',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Activity list view for a single day
class _ActivityListView extends StatelessWidget {
  final int dayNo;
  final List<CarePlanEntity> activities;

  const _ActivityListView({
    required this.dayNo,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (activities.isEmpty) {
      return Center(
        child: Text(
          'Không có hoạt động nào cho ngày $dayNo',
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 4 * scale,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1;

        return _ActivityItem(
          activity: activity,
          isLast: isLast,
        );
      },
    );
  }
}

/// Single activity item with timeline
class _ActivityItem extends StatelessWidget {
  final CarePlanEntity activity;
  final bool isLast;

  const _ActivityItem({
    required this.activity,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 24 * scale,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 12 * scale,
                  height: 12 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4 * scale,
                      ),
                    ],
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2 * scale,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          // Activity card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 12 * scale),
              padding: EdgeInsets.all(14 * scale),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      '${activity.startTime} - ${activity.endTime}',
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  // Activity name
                  Text(
                    activity.activityName,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // Instruction
                  if (activity.instruction != null &&
                      activity.instruction!.isNotEmpty) ...[
                    SizedBox(height: 6 * scale),
                    Text(
                      activity.instruction!,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
