import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/health_record/domain/entities/health_record_entity.dart';
import '../../../../../features/health_record/presentation/bloc/health_record_bloc.dart';
import '../../../../../features/health_record/presentation/bloc/health_record_event.dart';
import '../../../../../features/health_record/presentation/bloc/health_record_state.dart';

class StaffHealthRecordHistoryScreen extends StatefulWidget {
  final int familyProfileId;
  final String familyMemberName;
  final String? memberType;
  final String? avatarUrl;

  const StaffHealthRecordHistoryScreen({
    super.key,
    required this.familyProfileId,
    required this.familyMemberName,
    this.memberType,
    this.avatarUrl,
  });

  @override
  State<StaffHealthRecordHistoryScreen> createState() => _StaffHealthRecordHistoryScreenState();
}

class _StaffHealthRecordHistoryScreenState extends State<StaffHealthRecordHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  late HealthRecordBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  bool get isBaby {
    final type = widget.memberType?.toLowerCase() ?? '';
    return type.contains('baby') || type.contains('bé') || type.contains('trẻ');
  }

  @override
  void initState() {
    super.initState();
    _bloc = InjectionContainer.healthRecordBloc;
    _loadRecords();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRecords() {
    _bloc.add(GetHealthRecords(
      widget.familyProfileId,
      fromDate: _fromDate,
      toDate: _toDate,
    ));
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocBuilder<HealthRecordBloc, HealthRecordState>(
          builder: (context, state) {
            List<HealthRecordEntity> records = [];
            bool isLoading = state is HealthRecordLoading;
            if (state is HealthRecordLoaded) {
              records = state.records;
            }

            return Stack(
              children: [
                _buildMainContent(records, isLoading, scale),
                _buildCustomAppBar(scale),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(double scale) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 110 * scale,
        padding: EdgeInsets.fromLTRB(10 * scale, 50 * scale, 10 * scale, 0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Tệp hồ sơ sức khoẻ',
                textAlign: TextAlign.center,
                style: AppTextStyles.arimo(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _fromDate != null ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                color: AppColors.primary,
              ),
              onPressed: _selectDateRange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(List<HealthRecordEntity> records, bool isLoading, double scale) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 120 * scale)),
        _buildHeroSection(scale),
        _buildQuickFilter(scale),
        if (isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
        else if (records.isEmpty)
          SliverFillRemaining(child: _buildEmptyState(scale))
        else ...[
          _buildLatestSnapshot(records, scale),
          _buildHistoryTimeline(records, scale),
          SliverToBoxAdapter(child: SizedBox(height: 100 * scale)),
        ],
      ],
    );
  }

  Widget _buildHeroSection(double scale) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20 * scale),
        height: 140 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32 * scale),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32 * scale),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient Overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.85),
                        const Color(0xFF6366F1).withValues(alpha: 0.6),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3 * scale),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 32 * scale,
                        backgroundColor: AppColors.background,
                        backgroundImage: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                            ? NetworkImage(widget.avatarUrl!)
                            : null,
                        child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                            ? Icon(
                                isBaby ? Icons.child_care_rounded : Icons.person_rounded,
                                color: AppColors.primary,
                                size: 36 * scale,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.familyMemberName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.arimo(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10 * scale),
                            ),
                            child: Text(
                              isBaby ? 'Bé sơ sinh' : 'Người mẹ',
                              style: AppTextStyles.arimo(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilter(double scale) {
    final df = DateFormat('dd/MM/yyyy');
    final isFiltering = _fromDate != null && _toDate != null;

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(20 * scale, 24 * scale, 20 * scale, 12 * scale),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử ghi nhận',
              style: AppTextStyles.arimo(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            if (isFiltering)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _fromDate = null;
                    _toDate = null;
                  });
                  _loadRecords();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${df.format(_fromDate!)} - ${df.format(_toDate!)}',
                        style: AppTextStyles.arimo(fontSize: 11 * scale, color: AppColors.red, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 4 * scale),
                      const Icon(Icons.close_rounded, size: 14, color: AppColors.red),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestSnapshot(List<HealthRecordEntity> records, double scale) {
    if (records.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final latest = records.first;

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
        padding: EdgeInsets.all(20 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSnapshotItem('Cân nặng', '${latest.weight ?? "--"}', 'kg', Icons.monitor_weight_rounded, Colors.blue, scale),
                _buildSnapshotItem('Nhiệt độ', '${latest.temperature ?? "--"}', '°C', Icons.thermostat_rounded, Colors.orange, scale),
                _buildSnapshotItem('Chiều cao', '${latest.height ?? "--"}', 'cm', Icons.height_rounded, Colors.green, scale),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotItem(String label, String value, String unit, IconData icon, Color color, double scale) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20 * scale),
        ),
        SizedBox(height: 8 * scale),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.arimo(fontSize: 18 * scale, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 2 * scale, left: 1 * scale),
              child: Text(
                unit,
                style: AppTextStyles.arimo(fontSize: 10 * scale, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        Text(label, style: AppTextStyles.arimo(fontSize: 10 * scale, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildHistoryTimeline(List<HealthRecordEntity> records, double scale) {
    final sorted = List<HealthRecordEntity>.from(records)
      ..sort((a, b) {
        int cmp = b.recordDate.compareTo(a.recordDate);
        if (cmp == 0) return b.createdAt.compareTo(a.createdAt);
        return cmp;
      });

    final Map<String, List<HealthRecordEntity>> grouped = {};
    for (var r in sorted) {
      final dateKey = DateFormat('dd/MM/yyyy').format(r.recordDate);
      grouped.putIfAbsent(dateKey, () => []).add(r);
    }

    final dateKeys = grouped.keys.toList();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dateKey = dateKeys[index];
            final dayRecords = grouped[dateKey]!;
            return _buildTimelineDayGroup(dateKey, dayRecords, scale, index == 0);
          },
          childCount: dateKeys.length,
        ),
      ),
    );
  }

  Widget _buildTimelineDayGroup(String dateKey, List<HealthRecordEntity> dayRecords, double scale, bool isExpanded) {
    return Container(
      margin: EdgeInsets.only(bottom: 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
          title: Text(
            dateKey,
            style: AppTextStyles.arimo(fontWeight: FontWeight.w900, fontSize: 16 * scale, color: AppColors.textPrimary),
          ),
          subtitle: Text('${dayRecords.length} phiếu ghi nhận', style: AppTextStyles.arimo(fontSize: 12 * scale, color: AppColors.textSecondary)),
          leading: Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.calendar_today_rounded, size: 18 * scale, color: AppColors.primary),
          ),
          children: dayRecords.map((r) => _buildTimelineRecord(r, scale)).toList(),
        ),
      ),
    );
  }

  Widget _buildTimelineRecord(HealthRecordEntity record, double scale) {
    final displayTime = DateFormat('HH:mm').format(record.createdAt.toLocal());

    return Container(
      margin: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 16 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8 * scale)),
                    child: Text(
                      displayTime,
                      style: AppTextStyles.arimo(fontWeight: FontWeight.w900, fontSize: 12 * scale, color: Colors.white),
                    ),
                  ),
                  if (record.recordedByName != null) ...[
                    SizedBox(width: 8 * scale),
                    Text(
                      'bởi ${record.recordedByName}',
                      style: AppTextStyles.arimo(fontSize: 10 * scale, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniVital(record.weight, 'kg', Icons.monitor_weight_outlined, Colors.blue, scale),
              _buildMiniVital(record.temperature, '°C', Icons.thermostat_rounded, Colors.orange, scale),
              _buildMiniVital(record.height, 'cm', Icons.height_rounded, Colors.green, scale),
            ],
          ),
          if (record.generalCondition != null && record.generalCondition!.isNotEmpty) ...[
            SizedBox(height: 12 * scale),
            Text(
              record.generalCondition!,
              style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textPrimary, height: 1.4),
            ),
          ],
          if (record.conditions.isNotEmpty) ...[
            SizedBox(height: 12 * scale),
            _buildCategorizedConditions(record.conditions, scale),
          ],
          if (record.note != null && record.note!.isNotEmpty) ...[
            SizedBox(height: 12 * scale),
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.notes_rounded, size: 14 * scale, color: Colors.grey),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: Text(
                      record.note!,
                      style: AppTextStyles.arimo(fontSize: 11 * scale, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorizedConditions(List<HealthConditionEntity> conditions, double scale) {
    final Map<String, List<HealthConditionEntity>> categorized = {};
    for (var c in conditions) {
      final cat = c.category;
      categorized.putIfAbsent(cat, () => []).add(c);
    }

    final categoryLabels = {
      'Chronic': 'Tình trạng / Bệnh lý',
      'Delivery': 'Thông tin sinh',
      'Preference': 'Sở thích / Ăn kiêng',
      'Other': 'Khác',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categorized.entries.map((entry) {
        final label = categoryLabels[entry.key] ?? entry.key;
        return Padding(
          padding: EdgeInsets.only(bottom: 8 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4 * scale),
              Wrap(
                spacing: 6 * scale,
                runSpacing: 6 * scale,
                children: entry.value.map((c) => _buildModernChip(c.name, scale)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniVital(double? value, String unit, IconData icon, Color color, double scale) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14 * scale),
        SizedBox(width: 4 * scale),
        Text(
          '${value ?? "--"}',
          style: AppTextStyles.arimo(fontWeight: FontWeight.w800, fontSize: 13 * scale, color: AppColors.textPrimary),
        ),
        Text(' $unit', style: AppTextStyles.arimo(fontSize: 9 * scale, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildModernChip(String label, double scale) {
    IconData icon = Icons.check_circle_outline_rounded;
    final l = label.toLowerCase();
    if (l.contains('mổ')) icon = Icons.content_cut_rounded;
    if (l.contains('thiếu máu') || l.contains('máu')) icon = Icons.bloodtype_rounded;
    if (l.contains('ăn kiêng') || l.contains('ăn')) icon = Icons.restaurant_rounded;
    if (l.contains('sốt')) icon = Icons.thermostat_rounded;
    if (l.contains('ho')) icon = Icons.record_voice_over_rounded;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12 * scale, color: AppColors.primary),
          SizedBox(width: 4 * scale),
          Text(
            label,
            style: AppTextStyles.arimo(fontSize: 10 * scale, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80 * scale, color: Colors.grey[300]),
          SizedBox(height: 16 * scale),
          Text(
            'Hồ sơ đang trống',
            style: AppTextStyles.arimo(fontSize: 18 * scale, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Chưa có dữ liệu sức khỏe nào được ghi nhận.',
            style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
