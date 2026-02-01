import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../bloc/care_plan_bloc.dart';
import '../bloc/care_plan_event.dart';
import '../bloc/care_plan_state.dart';
import 'care_plan_timeline_view.dart';

class CarePlanBottomSheet extends StatefulWidget {
  final int packageId;
  final String packageName;

  const CarePlanBottomSheet({
    super.key,
    required this.packageId,
    required this.packageName,
  });

  static void show(
    BuildContext context, {
    required int packageId,
    required String packageName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => InjectionContainer.carePlanBloc
          ..add(CarePlanLoadRequested(packageId)),
        child: CarePlanBottomSheet(
          packageId: packageId,
          packageName: packageName,
        ),
      ),
    );
  }

  @override
  State<CarePlanBottomSheet> createState() => _CarePlanBottomSheetState();
}

class _CarePlanBottomSheetState extends State<CarePlanBottomSheet> {
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

    return Container(
      height: screenHeight * 0.85,
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
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 16 * scale,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.carePlanTitle,
                        style: AppTextStyles.tinos(
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        widget.packageName,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24 * scale,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Date picker (dayNo)
          BlocBuilder<CarePlanBloc, CarePlanState>(
            builder: (context, state) {
              if (state is CarePlanLoaded) {
                final availableDays = _getAvailableDays(state.carePlans);
                if (availableDays.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                // Update current index if needed (after build)
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
          SizedBox(height: 16 * scale),
          // Timeline view with horizontal scroll
          Expanded(
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
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state is CarePlanLoaded) {
                  final availableDays = _getAvailableDays(state.carePlans);
                  
                  // Update state after build if needed
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
                            size: 64 * scale,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            AppStrings.noCarePlanDetails,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
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
                        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                      return CarePlanTimelineView(
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
    );
  }
}

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
      height: 60 * scale,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableDays.length,
        itemBuilder: (context, index) {
          final dayNo = availableDays[index];
          final isSelected = dayNo == selectedDayNo;

          return GestureDetector(
            onTap: () => onDaySelected(dayNo),
            child: Container(
              margin: EdgeInsets.only(right: 12 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 20 * scale,
                vertical: 10 * scale,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.borderLight,
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
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textPrimary,
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
