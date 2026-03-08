import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/home_activity_entity.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../bloc/home_service_bloc.dart';
import '../bloc/home_service_event.dart';
import '../bloc/home_service_state.dart';

class HomeServiceStep2TimeSelection extends StatelessWidget {
  const HomeServiceStep2TimeSelection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<HomeServiceBloc, HomeServiceState>(
      builder: (context, state) {
        if (state is HomeServiceLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        final selections = _extractSelections(state);
        if (selections == null) {
          return const Center(child: AppLoadingIndicator());
        }

        final hasSelectedActivities = selections.isNotEmpty;

        return SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16 * scale),
                  children: [
                    Text(
                      AppStrings.homeServiceSelectDateTimeForEachService,
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    if (!hasSelectedActivities)
                      Text(
                        AppStrings.homeServiceGoBackToSelectService,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      ...selections.map(
                        (selection) => _SelectionCard(
                          key: ValueKey(selection.activity.id),
                          selection: selection,
                        ),
                      ),
                    SizedBox(height: 8 * scale),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<HomeServiceSelectionEntity>? _extractSelections(HomeServiceState state) {
    if (state is HomeServiceActivitiesLoaded) {
      return state.selections;
    }
    if (state is HomeServiceFreeStaffLoaded) {
      return state.selections;
    }
    if (state is HomeServiceSummaryReady) {
      return state.selections;
    }
    return null;
  }
}

class _SelectionCard extends StatelessWidget {
  final HomeServiceSelectionEntity selection;

  const _SelectionCard({super.key, required this.selection});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final entries = selection.dateTimeSlots.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      margin: EdgeInsets.only(bottom: 14 * scale),
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selection.activity.name,
            style: AppTextStyles.tinos(
              fontSize: 17 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Text(
                '${selection.activity.duration} ${AppStrings.homeServiceMinutes}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 10 * scale),
              Text(
                _formatCurrency(selection.activity.price),
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          AppWidgets.primaryButton(
            text: AppStrings.homeServiceAddDate,
            onPressed: () async {
              final pickedDates =
                  await _openMultiDatePicker(context, selection.dateTimeSlots.keys);
              if (!context.mounted || pickedDates.isEmpty) return;

              for (final date in pickedDates) {
                context.read<HomeServiceBloc>().add(
                      HomeServiceSelectActivityAndDate(
                        activity: selection.activity,
                        date: date,
                      ),
                    );
              }
            },
          ),
          if (entries.isNotEmpty) ...[
            SizedBox(height: 10 * scale),
            ...entries.map(
              (entry) => _DateTimeRow(
                key: ValueKey(
                  '${selection.activity.id}-${entry.key.toIso8601String()}',
                ),
                date: entry.key,
                slot: entry.value,
                durationMinutes: selection.activity.duration,
                activity: selection.activity,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<List<DateTime>> _openMultiDatePicker(
    BuildContext context,
    Iterable<DateTime> existingDates,
  ) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = firstDate.add(const Duration(days: 180));
    final initial = existingDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    final result = await showDialog<List<DateTime>>(
      context: context,
      builder: (dialogContext) {
        final selected = <DateTime>{...initial};
        DateTime focusedMonth = DateTime(firstDate.year, firstDate.month, 1);

        bool isInRange(DateTime date) {
          return !date.isBefore(firstDate) && !date.isAfter(lastDate);
        }

        String monthLabel(DateTime month) {
          const monthNames = [
            AppStrings.month1,
            AppStrings.month2,
            AppStrings.month3,
            AppStrings.month4,
            AppStrings.month5,
            AppStrings.month6,
            AppStrings.month7,
            AppStrings.month8,
            AppStrings.month9,
            AppStrings.month10,
            AppStrings.month11,
            AppStrings.month12,
          ];
          return '${monthNames[month.month - 1]} ${month.year}';
        }

        List<DateTime?> buildMonthGrid(DateTime month) {
          final firstOfMonth = DateTime(month.year, month.month, 1);
          final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
          final firstWeekday = firstOfMonth.weekday; // 1=Mon..7=Sun

          final grid = <DateTime?>[];
          final leadingEmpty = firstWeekday % 7; // Sun-first layout
          for (int i = 0; i < leadingEmpty; i++) {
            grid.add(null);
          }
          for (int d = 1; d <= daysInMonth; d++) {
            grid.add(DateTime(month.year, month.month, d));
          }
          while (grid.length % 7 != 0) {
            grid.add(null);
          }
          return grid;
        }

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final grid = buildMonthGrid(focusedMonth);
            final canGoPrev = !DateTime(
              focusedMonth.year,
              focusedMonth.month,
              1,
            ).isAtSameMomentAs(DateTime(firstDate.year, firstDate.month, 1));
            final canGoNext = DateTime(
              focusedMonth.year,
              focusedMonth.month,
              1,
            ).isBefore(DateTime(lastDate.year, lastDate.month, 1));

            return Dialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.homeServicePickMultipleDates,
                        style: AppTextStyles.tinos(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              monthLabel(focusedMonth),
                              style: AppTextStyles.arimo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: canGoPrev
                                ? () {
                                    setStateDialog(() {
                                      focusedMonth = DateTime(
                                        focusedMonth.year,
                                        focusedMonth.month - 1,
                                        1,
                                      );
                                    });
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: canGoNext
                                ? () {
                                    setStateDialog(() {
                                      focusedMonth = DateTime(
                                        focusedMonth.year,
                                        focusedMonth.month + 1,
                                        1,
                                      );
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _WeekdayText(AppStrings.weekDaySunday),
                          _WeekdayText(AppStrings.weekDayMonday),
                          _WeekdayText(AppStrings.weekDayTuesday),
                          _WeekdayText(AppStrings.weekDayWednesday),
                          _WeekdayText(AppStrings.weekDayThursday),
                          _WeekdayText(AppStrings.weekDayFriday),
                          _WeekdayText(AppStrings.weekDaySaturday),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                        ),
                        itemCount: grid.length,
                        itemBuilder: (context, index) {
                          final date = grid[index];
                          if (date == null) return const SizedBox.shrink();

                          final normalized =
                              DateTime(date.year, date.month, date.day);
                          final isSelected = selected.contains(normalized);
                          final enabled = isInRange(normalized);

                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: enabled
                                ? () {
                                    setStateDialog(() {
                                      if (isSelected) {
                                        selected.remove(normalized);
                                      } else {
                                        selected.add(normalized);
                                      }
                                    });
                                  }
                                : null,
                            child: Center(
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${date.day}',
                                  style: AppTextStyles.arimo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: !enabled
                                        ? AppColors.textSecondary
                                            .withValues(alpha: 0.35)
                                        : isSelected
                                            ? AppColors.white
                                            : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${AppStrings.homeServiceSelectedDays} ${selected.length} ${AppStrings.homeServiceDays}',
                        style: AppTextStyles.arimo(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                                              TextButton(
                            onPressed: () => Navigator.of(dialogContext)
                                .pop(<DateTime>[]),
                            child: Text(AppStrings.homeServiceCancel),
                          ),
                          TextButton(
                            onPressed: () {
                              final list = selected.toList()..sort();
                              Navigator.of(dialogContext).pop(list);
                            },
                            child: Text(AppStrings.homeServiceDone),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return result ?? const [];
  }

  String _formatCurrency(double value) {
    final intValue = value.round();
    final str = intValue.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }

    final reversed = buffer.toString().split('').reversed.join();
    return '$reversed ${AppStrings.currencyUnit.trim()} ${AppStrings.homeServicePerSession}';
  }
}

class _WeekdayText extends StatelessWidget {
  final String text;

  const _WeekdayText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.arimo(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  final DateTime date;
  final ServiceTimeSlot slot;
  final int durationMinutes;
  final HomeActivityEntity activity;

  const _DateTimeRow({
    super.key,
    required this.date,
    required this.slot,
    required this.durationMinutes,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 8 * scale),
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: slot.startTime.hour,
                  minute: slot.startTime.minute,
                ),
              );

              if (picked == null || !context.mounted) return;

              final start = DateTime(
                date.year,
                date.month,
                date.day,
                picked.hour,
                picked.minute,
              );
              final end = start.add(Duration(minutes: durationMinutes));

              context.read<HomeServiceBloc>().add(
                    HomeServiceSelectTime(
                      activity: activity,
                      date: date,
                      startTime: start,
                      endTime: end,
                    ),
                  );
            },
            child: Text(AppStrings.homeServiceHour),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              context.read<HomeServiceBloc>().add(
                    HomeServiceRemoveActivityDate(
                      activity: activity,
                      date: date,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
