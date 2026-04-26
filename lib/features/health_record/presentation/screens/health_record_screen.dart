import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/health_record_entity.dart';
import '../bloc/health_record_bloc.dart';
import '../bloc/health_record_event.dart';
import '../bloc/health_record_state.dart';
import '../widgets/create_health_record_sheet.dart';
import '../../../../core/widgets/avatar_widget.dart';

class HealthRecordScreen extends StatefulWidget {
  final int familyProfileId;
  final bool isBaby;
  final String memberName;
  final String? avatarUrl;

  const HealthRecordScreen({
    super.key,
    required this.familyProfileId,
    required this.isBaby,
    required this.memberName,
    this.avatarUrl,
  });

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HealthRecordBloc>().add(GetHealthRecords(widget.familyProfileId));
  }

  void _showAddRecordSheet() {
    final height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: height * 0.9,
        ),
        child: BlocProvider.value(
          value: context.read<HealthRecordBloc>(),
          child: CreateHealthRecordSheet(
            familyProfileId: widget.familyProfileId,
            isBaby: widget.isBaby,
            memberName: widget.memberName,
            avatarUrl: widget.avatarUrl,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Hồ sơ sức khoẻ',
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16 * scale),
            child: AvatarWidget(
              imageUrl: widget.avatarUrl,
              displayName: widget.memberName,
              size: 32,
              fallbackIcon: widget.isBaby ? Icons.child_care_rounded : Icons.pregnant_woman_rounded,
            ),
          ),
        ],
      ),
      body: BlocConsumer<HealthRecordBloc, HealthRecordState>(
        listener: (context, state) {
          if (state is HealthRecordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is HealthRecordLoading || state is HealthRecordInitial) {
            return const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            );
          }

          if (state is HealthRecordLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return _buildEmptyState(scale);
            }
            return _buildRecordsList(scale, records);
          }

          return _buildEmptyState(scale);
        },
      ),
      floatingActionButton: AppWidgets.primaryFabExtendedIconOnly(
        context: context,
        icon: Icons.add_rounded,
        onPressed: _showAddRecordSheet,
      ),
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.medical_information_outlined,
                size: 64 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              'Chưa có hồ sơ sức khoẻ',
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Bấm vào nút + bên dưới để thêm hồ sơ sức khoẻ mới.',
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

  Widget _buildRecordsList(double scale, List<HealthRecordEntity> records) {
    // Sort records by date descending
    final sortedRecords = List<HealthRecordEntity>.from(records)
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HealthRecordBloc>().add(GetHealthRecords(widget.familyProfileId));
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8 * scale),
        itemCount: sortedRecords.length,
        itemBuilder: (context, index) {
          final record = sortedRecords[index];
          return _buildRecordCard(scale, record);
        },
      ),
    );
  }

  Widget _buildRecordCard(double scale, HealthRecordEntity record) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Date
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
                border: const Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 4 * scale,
                        ),
                      ],
                    ),
                    child: Icon(Icons.calendar_month_rounded, size: 16 * scale, color: AppColors.primary),
                  ),
                  SizedBox(width: 10 * scale),
                  Text(
                    _formatDate(record.recordDate),
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Specific Conditions (Pills) - More prominent
                  if (record.conditions.isNotEmpty) ...[
                    Wrap(
                      spacing: 8 * scale,
                      runSpacing: 8 * scale,
                      children: record.conditions.map((c) => AppWidgets.pillBadge(
                        context,
                        text: c.name,
                        icon: Icons.medical_information_rounded,
                        background: AppColors.primary,
                        textColor: AppColors.white,
                        borderColor: AppColors.primary,
                      )).toList(),
                    ),
                    SizedBox(height: 16 * scale),
                  ],

                  // Metrics Grid - Structured Layout
                  Column(
                    children: [
                      if (widget.isBaby) ...[
                        if (record.gestationalAgeWeeks != null || record.birthWeightGrams != null)
                          Row(
                            children: [
                              if (record.gestationalAgeWeeks != null)
                                Expanded(child: _buildMetricBox(scale, Icons.child_care_rounded, 'Tuần thai', '${record.gestationalAgeWeeks} tuần', Colors.blue)),
                              if (record.gestationalAgeWeeks != null && record.birthWeightGrams != null) SizedBox(width: 12 * scale),
                              if (record.birthWeightGrams != null)
                                Expanded(child: _buildMetricBox(scale, Icons.scale_rounded, 'Lúc sinh', '${record.birthWeightGrams} g', Colors.blue)),
                            ],
                          ),
                      ] else ...[
                        if (record.weight != null || record.height != null)
                          Row(
                            children: [
                              if (record.weight != null)
                                Expanded(child: _buildMetricBox(scale, Icons.monitor_weight_outlined, 'Cân nặng', '${record.weight} kg', Colors.blue)),
                              if (record.weight != null && record.height != null) SizedBox(width: 12 * scale),
                              if (record.height != null)
                                Expanded(child: _buildMetricBox(scale, Icons.height_rounded, 'Chiều cao', '${record.height} cm', Colors.blue)),
                            ],
                          ),
                      ],
                      if (record.temperature != null) ...[
                        SizedBox(height: 12 * scale),
                        _buildMetricBox(scale, Icons.device_thermostat_rounded, 'Nhiệt độ cơ thể', '${record.temperature} °C', Colors.blue, isFullWidth: true),
                      ],
                    ],
                  ),

                  // General Condition & Notes
                  if ((record.generalCondition != null && record.generalCondition!.isNotEmpty) || 
                      (record.note != null && record.note!.isNotEmpty)) ...[
                    SizedBox(height: 16 * scale),
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (record.generalCondition != null && record.generalCondition!.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded, size: 16 * scale, color: AppColors.textSecondary),
                                SizedBox(width: 8 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tình trạng chung',
                                        style: AppTextStyles.arimo(fontSize: 12 * scale, color: AppColors.textSecondary),
                                      ),
                                      SizedBox(height: 2 * scale),
                                      Text(
                                        record.generalCondition!,
                                        style: AppTextStyles.arimo(fontSize: 14 * scale, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (record.generalCondition != null && record.generalCondition!.isNotEmpty && record.note != null && record.note!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8 * scale),
                              child: Divider(height: 1, color: AppColors.borderLight.withValues(alpha: 0.5)),
                            ),
                          if (record.note != null && record.note!.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.edit_note_rounded, size: 16 * scale, color: AppColors.textSecondary),
                                SizedBox(width: 8 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ghi chú',
                                        style: AppTextStyles.arimo(fontSize: 12 * scale, color: AppColors.textSecondary),
                                      ),
                                      SizedBox(height: 2 * scale),
                                      Text(
                                        record.note!,
                                        style: AppTextStyles.arimo(fontSize: 14 * scale, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(double scale, IconData icon, String label, String value, MaterialColor color, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16 * scale, color: AppColors.primary),
              SizedBox(width: 6 * scale),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            value,
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
