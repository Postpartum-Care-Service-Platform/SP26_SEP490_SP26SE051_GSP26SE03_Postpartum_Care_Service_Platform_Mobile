import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../features/employee/room/domain/entities/room_entity.dart';
import '../../../../../features/employee/room/domain/entities/room_status.dart';
import '../../../../../features/employee/room/presentation/bloc/room/room_bloc.dart';
import '../../../../../features/employee/room/presentation/bloc/room/room_event.dart';
import '../../../../../features/employee/room/presentation/bloc/room/room_state.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';

/// Booking filter options for rooms.
enum BookingFilter {
  all,
  occupied,
  upcoming,
  empty,
}

enum BookingState {
  occupied,
  upcoming,
  empty,
}

DateTime _normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

BookingState _getBookingState(RoomEntity room, DateTime now) {
  if (room.isOccupied) return BookingState.occupied;

  final startDate = room.bookingStartDate;
  final endDate = room.bookingEndDate;
  final nowDate = _normalizeDate(now);

  if (startDate != null && endDate != null) {
    final start = _normalizeDate(startDate);
    final end = _normalizeDate(endDate);
    if (nowDate.isBefore(start)) return BookingState.upcoming;
    if (nowDate.isAfter(end)) return BookingState.empty;
  }

  if (startDate != null && nowDate.isBefore(_normalizeDate(startDate))) {
    return BookingState.upcoming;
  }

  return BookingState.empty;
}

class EmployeeRoomsScreen extends StatelessWidget {
  const EmployeeRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectionContainer.roomBloc..add(const LoadAllRooms()),
      child: const _EmployeeRoomsView(),
    );
  }
}

class _EmployeeRoomsView extends StatefulWidget {
  const _EmployeeRoomsView();

  @override
  State<_EmployeeRoomsView> createState() => _EmployeeRoomsViewState();
}

class _EmployeeRoomsViewState extends State<_EmployeeRoomsView> {
  BookingFilter _selectedFilter = BookingFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return EmployeeScaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý Phòng ở',
          style: AppTextStyles.tinos(
            fontSize: 22 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<RoomBloc>().add(const RefreshRooms()),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading || state is RoomInitial) {
            return const Center(child: AppLoadingIndicator(color: AppColors.primary));
          }

          if (state is RoomError) {
            return _buildErrorState(state.message, scale);
          }

          if (state is RoomEmpty) {
            return _buildEmptyState(scale);
          }

          if (state is RoomLoaded) {
            final allRooms = state.rooms;
            final filteredBySearch = allRooms.where((room) {
              final query = _searchQuery.toLowerCase();
              return room.name.toLowerCase().contains(query) ||
                  room.roomTypeName.toLowerCase().contains(query);
            }).toList();

            final sortedRooms = [...filteredBySearch]
              ..sort((a, b) {
                final floorA = a.floor ?? -1;
                final floorB = b.floor ?? -1;
                if (floorA != floorB) return floorA.compareTo(floorB);
                return a.name.compareTo(b.name);
              });

            final floors = _extractFloors(sortedRooms);

            return DefaultTabController(
              length: floors.length,
              child: Column(
                children: [
                  _buildSearchBar(scale),
                  _FloorTabBar(floors: floors, scale: scale),
                  _BookingFilterBar(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) => setState(() => _selectedFilter = filter),
                    scale: scale,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: floors.map((floor) {
                        final floorRooms = sortedRooms.where((room) {
                          if (floor.isAllFloors) return true;
                          if (floor.isUnknownFloor) return room.floor == null;
                          return room.floor == floor.value;
                        }).toList();

                        final filteredRooms = _applyBookingFilter(floorRooms, _selectedFilter);

                        if (filteredRooms.isEmpty) {
                          return _buildNoResultsState(scale);
                        }

                        return GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: AppResponsive.isTablet(context) ? 3 : 2,
                            childAspectRatio: 1.15, // More compact aspect ratio
                            crossAxisSpacing: 10 * scale,
                            mainAxisSpacing: 10 * scale,
                          ),
                          itemCount: filteredRooms.length,
                          itemBuilder: (context, index) => _RoomCard(
                            room: filteredRooms[index],
                            scale: scale,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      child: Container(
        height: 48 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15 * scale,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm tên phòng hoặc loại phòng...',
            hintStyle: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.third),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 22 * scale),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: AppColors.third, size: 20 * scale),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12 * scale),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56 * scale, color: AppColors.red),
            SizedBox(height: 16 * scale),
            Text(
              'Đã xảy ra lỗi khi tải dữ liệu',
              style: AppTextStyles.tinos(fontSize: 18 * scale, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24 * scale),
            ElevatedButton(
              onPressed: () => context.read<RoomBloc>().add(const LoadAllRooms()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined, size: 72 * scale, color: AppColors.third),
          SizedBox(height: 16 * scale),
          Text(
            'Chưa có dữ liệu phòng',
            style: AppTextStyles.tinos(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56 * scale, color: AppColors.third),
          SizedBox(height: 12 * scale),
          Text(
            'Không tìm thấy phòng phù hợp',
            style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  List<_FloorTabData> _extractFloors(List<RoomEntity> rooms) {
    final floorsSet = <int?>{};
    for (final room in rooms) {
      floorsSet.add(room.floor);
    }

    final sorted = floorsSet.toList()
      ..sort((a, b) {
        final valueA = a ?? -1;
        final valueB = b ?? -1;
        return valueA.compareTo(valueB);
      });

    final results = <_FloorTabData>[];
    results.add(const _FloorTabData.all());

    for (final floor in sorted) {
      if (floor == null) {
        results.add(const _FloorTabData.unknown());
      } else {
        results.add(
          _FloorTabData(
            value: floor,
            label: 'Tầng $floor',
            isAllFloors: false,
            isUnknownFloor: false,
          ),
        );
      }
    }

    return results;
  }

  List<RoomEntity> _applyBookingFilter(List<RoomEntity> rooms, BookingFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case BookingFilter.all:
        return rooms;
      case BookingFilter.occupied:
        return rooms.where((room) => _getBookingState(room, now) == BookingState.occupied).toList();
      case BookingFilter.upcoming:
        return rooms.where((room) => _getBookingState(room, now) == BookingState.upcoming).toList();
      case BookingFilter.empty:
        return rooms.where((room) => _getBookingState(room, now) == BookingState.empty).toList();
    }
  }
}

class _FloorTabData {
  final int? value;
  final String label;
  final bool isAllFloors;
  final bool isUnknownFloor;

  const _FloorTabData({
    required this.value,
    required this.label,
    required this.isAllFloors,
    required this.isUnknownFloor,
  });

  const _FloorTabData.all()
    : value = null,
      label = 'Tất cả',
      isAllFloors = true,
      isUnknownFloor = false;

  const _FloorTabData.unknown()
    : value = null,
      label = 'Khác',
      isAllFloors = false,
      isUnknownFloor = true;
}

class _FloorTabBar extends StatelessWidget {
  final List<_FloorTabData> floors;
  final double scale;

  const _FloorTabBar({required this.floors, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16 * scale, 4 * scale, 16 * scale, 0),
      height: 44 * scale,
      child: TabBar(
        isScrollable: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scale),
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10 * scale,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.arimo(fontSize: 14 * scale, fontWeight: FontWeight.w700),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: 16 * scale),
        tabs: floors.map((floor) => Tab(text: floor.label)).toList(),
      ),
    );
  }
}

class _BookingFilterBar extends StatelessWidget {
  final BookingFilter selectedFilter;
  final ValueChanged<BookingFilter> onSelected;
  final double scale;

  const _BookingFilterBar({
    required this.selectedFilter,
    required this.onSelected,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả',
            isSelected: selectedFilter == BookingFilter.all,
            onTap: () => onSelected(BookingFilter.all),
            scale: scale,
          ),
          SizedBox(width: 8 * scale),
          _FilterChip(
            label: 'Đang ở',
            isSelected: selectedFilter == BookingFilter.occupied,
            onTap: () => onSelected(BookingFilter.occupied),
            color: const Color(0xFFEF4444),
            scale: scale,
          ),
          SizedBox(width: 8 * scale),
          _FilterChip(
            label: 'Sắp tới',
            isSelected: selectedFilter == BookingFilter.upcoming,
            onTap: () => onSelected(BookingFilter.upcoming),
            color: const Color(0xFF3B82F6),
            scale: scale,
          ),
          SizedBox(width: 8 * scale),
          _FilterChip(
            label: 'Trống',
            isSelected: selectedFilter == BookingFilter.empty,
            onTap: () => onSelected(BookingFilter.empty),
            color: const Color(0xFF10B981),
            scale: scale,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final double scale;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          color: isSelected ? displayColor : Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: isSelected ? displayColor : AppColors.borderLight.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: displayColor.withValues(alpha: 0.2),
              blurRadius: 8 * scale,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomEntity room;
  final double scale;

  const _RoomCard({required this.room, required this.scale});

  @override
  Widget build(BuildContext context) {
    final state = _getBookingState(room, DateTime.now());
    final statusColor = _getStatusColor(state);
    final statusText = _getStatusText(state);

    String? dateInfo;
    if (state == BookingState.occupied && room.bookingEndDate != null) {
      dateInfo = DateFormat('dd/MM').format(room.bookingEndDate!);
    } else if (state == BookingState.upcoming && room.bookingStartDate != null) {
      dateInfo = DateFormat('dd/MM').format(room.bookingStartDate!);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15 * scale,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background ghost icon for texture
          Positioned(
            right: -10 * scale,
            bottom: -10 * scale,
            child: Icon(
              _getStatusIcon(state),
              size: 80 * scale,
              color: statusColor.withValues(alpha: 0.04),
            ),
          ),
          // Main Content
          Padding(
            padding: EdgeInsets.all(14 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(state), size: 12 * scale, color: statusColor),
                          SizedBox(width: 4 * scale),
                          Text(
                            'T${room.floor ?? '?' }',
                            style: AppTextStyles.arimo(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (dateInfo != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6 * scale),
                          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          dateInfo,
                          style: AppTextStyles.arimo(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  room.name,
                  style: AppTextStyles.tinos(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2 * scale),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 10 * scale, color: AppColors.third),
                    SizedBox(width: 4 * scale),
                    Expanded(
                      child: Text(
                        room.roomTypeName,
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * scale),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 6 * scale,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arimo(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Interactive layer
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Action for room detail
                },
                borderRadius: BorderRadius.circular(20 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingState state) {
    switch (state) {
      case BookingState.occupied: return const Color(0xFFEF4444);
      case BookingState.upcoming: return const Color(0xFF3B82F6);
      case BookingState.empty: return const Color(0xFF10B981);
    }
  }

  String _getStatusText(BookingState state) {
    switch (state) {
      case BookingState.occupied: return 'ĐANG CÓ KHÁCH';
      case BookingState.upcoming: return 'ĐÃ ĐƯỢC ĐẶT';
      case BookingState.empty: return 'ĐANG TRỐNG';
    }
  }

  IconData _getStatusIcon(BookingState state) {
    switch (state) {
      case BookingState.occupied: return Icons.person_rounded;
      case BookingState.upcoming: return Icons.event_available_rounded;
      case BookingState.empty: return Icons.no_meeting_room_rounded;
    }
  }
}
