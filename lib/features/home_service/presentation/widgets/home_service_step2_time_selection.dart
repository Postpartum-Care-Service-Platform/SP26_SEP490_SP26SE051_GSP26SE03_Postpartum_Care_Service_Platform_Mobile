import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
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

    // Lấy time slot chung (từ entry đầu tiên nếu có)
    final currentSlot = entries.isNotEmpty ? entries.first.value : null;

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
          // Activity name
          Text(
            selection.activity.name,
            style: AppTextStyles.tinos(
              fontSize: 17 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8 * scale),
          // Duration & Price
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
          SizedBox(height: 12 * scale),

          // Khung giờ chung (1 lần duy nhất)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 10 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 20 * scale,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khung giờ chung',
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        currentSlot != null
                            ? '${_formatTime(currentSlot.startTime)} - ${_formatTime(currentSlot.endTime)}'
                            : '08:00 - ${_formatDefaultEndTime(selection.activity.duration)}',
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _TimePickerButton(
                  scale: scale,
                  currentSlot: currentSlot,
                  durationMinutes: selection.activity.duration,
                  activity: selection.activity,
                  dates: entries.map((e) => e.key).toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 12 * scale),

          // Nút thêm ngày
          SizedBox(
            width: double.infinity,
            height: 52 * scale,
            child: OutlinedButton(
              onPressed: () async {
                final pickedDates = await _openMultiDatePicker(
                    context, selection.dateTimeSlots.keys);
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
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
              ),
              child: Text(
                AppStrings.homeServiceAddDate,
                style: AppTextStyles.arimo(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Danh sách ngày đã chọn
          if (entries.isNotEmpty) ...[
            SizedBox(height: 10 * scale),
            ...entries.map(
              (entry) => _DateRow(
                key: ValueKey(
                  '${selection.activity.id}-${entry.key.toIso8601String()}',
                ),
                date: entry.key,
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
    final initial =
        existingDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

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
          final firstWeekday = firstOfMonth.weekday;

          final grid = <DateTime?>[];
          final leadingEmpty = firstWeekday % 7;
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
            ).isAtSameMomentAs(
                DateTime(firstDate.year, firstDate.month, 1));
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
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(<DateTime>[]),
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

  String _formatCurrency(double? value) {
    if (value == null) {
      return AppStrings.bookingPriceNotAvailable;
    }

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

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _formatDefaultEndTime(int durationMinutes) {
    final endHour = 8 + (durationMinutes ~/ 60);
    final endMinute = durationMinutes % 60;
    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
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

/// Nút đổi giờ chung
class _TimePickerButton extends StatelessWidget {
  final double scale;
  final ServiceTimeSlot? currentSlot;
  final int durationMinutes;
  final HomeActivityEntity activity;
  final List<DateTime> dates;

  const _TimePickerButton({
    required this.scale,
    required this.currentSlot,
    required this.durationMinutes,
    required this.activity,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8 * scale),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8 * scale),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: currentSlot != null
                ? TimeOfDay(
                    hour: currentSlot!.startTime.hour,
                    minute: currentSlot!.startTime.minute,
                  )
                : const TimeOfDay(hour: 8, minute: 0),
          );

          if (picked == null || !context.mounted) return;

          // Lấy 1 ngày bất kỳ để tạo event (bloc sẽ áp dụng cho tất cả các ngày)
          final referenceDate =
              dates.isNotEmpty ? dates.first : DateTime.now();

          final start = DateTime(
            referenceDate.year,
            referenceDate.month,
            referenceDate.day,
            picked.hour,
            picked.minute,
          );
          final end = start.add(Duration(minutes: durationMinutes));

          context.read<HomeServiceBloc>().add(
                HomeServiceSelectTime(
                  activity: activity,
                  date: referenceDate,
                  startTime: start,
                  endTime: end,
                ),
              );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 8 * scale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_rounded,
                size: 14 * scale,
                color: AppColors.primary,
              ),
              SizedBox(width: 4 * scale),
              Text(
                'Đổi giờ',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hàng ngày (chỉ hiện ngày + nút xóa, không có time picker riêng)
class _DateRow extends StatelessWidget {
  final DateTime date;
  final HomeActivityEntity activity;

  const _DateRow({
    super.key,
    required this.date,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 6 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16 * scale,
            color: AppColors.primary,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              _formatDate(date),
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<HomeServiceBloc>().add(
                    HomeServiceRemoveActivityDate(
                      activity: activity,
                      date: date,
                    ),
                  );
            },
            child: Icon(
              Icons.close_rounded,
              size: 18 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
