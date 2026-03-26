// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter/material.dart'; // Import Flutter material package.
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc package.

import '../../../../../core/constants/app_colors.dart'; // Import app colors.
import '../../../../../core/di/injection_container.dart'; // Import DI container.
import '../../../../../core/utils/app_text_styles.dart'; // Import text styles.
import '../../../../../features/employee/room/domain/entities/room_entity.dart'; // Import room entity.
import '../../../../../features/employee/room/domain/entities/room_status.dart'; // Import room status.
import '../../../../../features/employee/room/presentation/bloc/room/room_bloc.dart'; // Import room bloc.
import '../../../../../features/employee/room/presentation/bloc/room/room_event.dart'; // Import room events.
import '../../../../../features/employee/room/presentation/bloc/room/room_state.dart'; // Import room states.

/// Booking filter options for rooms.
enum BookingFilter {
  // Define booking filter enum.
  all, // Show all rooms.
  occupied, // Show rooms currently occupied.
  upcoming, // Show rooms with upcoming bookings.
  empty, // Show rooms with no bookings.
} // End booking filter enum.

enum BookingState {
  // Define booking state enum.
  occupied, // Currently occupied.
  upcoming, // Upcoming booking.
  empty, // No active booking.
} // End booking state enum.

DateTime _normalizeDate(DateTime value) {
  // Normalize date to day start.
  return DateTime(
    value.year,
    value.month,
    value.day,
  ); // Return normalized date.
} // End _normalizeDate.

BookingState _getBookingState(RoomEntity room, DateTime now) {
  // Get booking state.
  if (room.isOccupied) {
    // Check occupied.
    return BookingState.occupied; // Return occupied.
  } // End occupied.

  final startDate = room.bookingStartDate; // Get booking start date.
  final endDate = room.bookingEndDate; // Get booking end date.
  final nowDate = _normalizeDate(now); // Normalize now.

  if (startDate != null && endDate != null) {
    // Check booking range.
    final start = _normalizeDate(startDate); // Normalize start.
    final end = _normalizeDate(endDate); // Normalize end.
    if (nowDate.isBefore(start)) {
      // Upcoming booking.
      return BookingState.upcoming; // Return upcoming.
    } // End upcoming.
    if (nowDate.isAfter(end)) {
      // Past booking.
      return BookingState.empty; // Return empty.
    } // End past booking.
  } // End range check.

  if (startDate != null && nowDate.isBefore(_normalizeDate(startDate))) {
    // Upcoming without end.
    return BookingState.upcoming; // Return upcoming.
  } // End upcoming without end.

  return BookingState.empty; // Default empty.
} // End _getBookingState.

class EmployeeRoomsScreen extends StatelessWidget {
  // Define EmployeeRoomsScreen widget.
  const EmployeeRoomsScreen({super.key}); // Constructor.

  @override
  Widget build(BuildContext context) {
    // Build widget.
    return BlocProvider(
      // Provide RoomBloc to subtree.
      create: (_) =>
          InjectionContainer.roomBloc
            ..add(const LoadAllRooms()), // Create bloc and load rooms.
      child: const _EmployeeRoomsView(), // Render view.
    ); // End BlocProvider.
  } // End build.
} // End EmployeeRoomsScreen.

class _EmployeeRoomsView extends StatefulWidget {
  // Define stateful rooms view.
  const _EmployeeRoomsView(); // Constructor.

  @override
  State<_EmployeeRoomsView> createState() => _EmployeeRoomsViewState(); // Create state.
} // End _EmployeeRoomsView.

class _EmployeeRoomsViewState extends State<_EmployeeRoomsView> {
  // Define state for rooms view.
  BookingFilter _selectedFilter =
      BookingFilter.all; // Track current booking filter.

  @override
  Widget build(BuildContext context) {
    // Build UI.
    return Scaffold(
      // Build scaffold.
      backgroundColor: AppColors.background, // Set background color.
      appBar: AppBar(
        // Build app bar.
        title: const Text('Phòng ở'), // Set title.
        backgroundColor: AppColors.background, // Set app bar background.
        foregroundColor: AppColors.textPrimary, // Set app bar foreground.
        elevation: 0, // Remove elevation.
        actions: [
          // Define app bar actions.
          IconButton(
            // Add refresh button.
            tooltip: 'Làm mới', // Tooltip text.
            onPressed: () => context.read<RoomBloc>().add(
              const RefreshRooms(),
            ), // Trigger refresh.
            icon: const Icon(Icons.refresh_rounded), // Refresh icon.
          ), // End IconButton.
        ], // End actions.
      ), // End AppBar.
      body: BlocBuilder<RoomBloc, RoomState>(
        // Build body based on RoomState.
        builder: (context, state) {
          // Build with state.
          if (state is RoomLoading || state is RoomInitial) {
            // Check loading state.
            return const Center(
              // Center loading indicator.
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ), // Loading indicator.
            ); // End Center.
          } // End loading state.

          if (state is RoomError) {
            // Check error state.
            return Center(
              // Center error message.
              child: Padding(
                // Add padding.
                padding: const EdgeInsets.all(20), // Padding value.
                child: Text(
                  // Error text.
                  'Không tải được danh sách phòng: ${state.message}', // Error message.
                  textAlign: TextAlign.center, // Center align.
                ), // End Text.
              ), // End Padding.
            ); // End Center.
          } // End error state.

          if (state is RoomEmpty) {
            // Check empty state.
            return const Center(
              child: Text('Hiện chưa có phòng nào.'),
            ); // Empty text.
          } // End empty state.

          if (state is RoomLoaded) {
            // Check loaded state.
            final rooms =
                [...state.rooms] // Clone list.
                  ..sort((a, b) {
                    // Sort rooms.
                    final floorA = a.floor ?? -1; // Determine floor A.
                    final floorB = b.floor ?? -1; // Determine floor B.
                    if (floorA != floorB) {
                      // Compare floors when different.
                      return floorA.compareTo(floorB); // Compare floors.
                    } // End floor compare.
                    return a.name.compareTo(b.name); // Compare names.
                  }); // End sort.

            final floors = _extractFloors(rooms); // Extract floor list.

            return DefaultTabController(
              // Build tab controller for floors.
              length: floors.length, // Set tab count.
              child: Column(
                // Build column layout.
                children: [
                  // Column children.
                  _FloorTabBar(floors: floors), // Render floor tabs.
                  _BookingFilterBar(
                    // Render booking filter bar.
                    selectedFilter: _selectedFilter, // Pass current filter.
                    onSelected: (filter) {
                      // Handle filter change.
                      setState(
                        () => _selectedFilter = filter,
                      ); // Update filter.
                    }, // End onSelected.
                  ), // End _BookingFilterBar.
                  Expanded(
                    // Expand tab view.
                    child: TabBarView(
                      // Build tab views.
                      children: floors.map((floor) {
                        // Map each floor to list.
                        final floorRooms = rooms.where((room) {
                          // Filter by floor.
                          if (floor.isAllFloors) {
                            // Check all floors tab.
                            return true; // Keep all floors when selected.
                          } // End all floors.
                          if (floor.isUnknownFloor) {
                            // Handle unknown floor.
                            return room.floor == null; // Match null floors.
                          } // End unknown floor.
                          return room.floor ==
                              floor.value; // Match floor value.
                        }).toList(); // Convert to list.

                        final filteredRooms = _applyBookingFilter(
                          // Apply booking filter.
                          floorRooms, // Rooms for floor.
                          _selectedFilter, // Selected filter.
                        ); // End filter.

                        if (filteredRooms.isEmpty) {
                          // Check empty list.
                          return const Center(
                            // Center empty text.
                            child: Text(
                              'Không có phòng phù hợp.',
                            ), // Empty message.
                          ); // End Center.
                        } // End empty list.

                        return ListView.separated(
                          // Build rooms list.
                          padding: const EdgeInsets.all(16), // List padding.
                          itemCount: filteredRooms.length, // Number of items.
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10), // Separator.
                          itemBuilder: (_, index) => _RoomCard(
                            room: filteredRooms[index],
                          ), // Build card.
                        ); // End ListView.
                      }).toList(), // End map.
                    ), // End TabBarView.
                  ), // End Expanded.
                ], // End children.
              ), // End Column.
            ); // End DefaultTabController.
          } // End RoomLoaded state.

          return const SizedBox.shrink(); // Fallback empty widget.
        }, // End builder.
      ), // End BlocBuilder.
    ); // End Scaffold.
  } // End build.

  List<_FloorTabData> _extractFloors(List<RoomEntity> rooms) {
    // Extract floor list.
    final floors = <int?>{}; // Initialize set.
    for (final room in rooms) {
      // Loop rooms.
      floors.add(room.floor); // Add floor.
    } // End loop.

    final sorted =
        floors
            .toList() // Convert to list.
          ..sort((a, b) {
            // Sort floors.
            final valueA = a ?? -1; // Map null to -1.
            final valueB = b ?? -1; // Map null to -1.
            return valueA.compareTo(valueB); // Compare values.
          }); // End sort.

    final results = <_FloorTabData>[]; // Init results list.
    results.add(const _FloorTabData.all()); // Add all floors tab.

    for (final floor in sorted) {
      // Loop sorted floors.
      if (floor == null) {
        // Handle null floor.
        results.add(const _FloorTabData.unknown()); // Add unknown tab.
      } else {
        // Handle normal floor.
        results.add(
          _FloorTabData(
            value: floor,
            label: 'Tầng $floor',
            isAllFloors: false,
            isUnknownFloor: false,
          ),
        ); // Add floor tab.
      } // End floor check.
    } // End loop.

    return results; // Return tab data.
  } // End _extractFloors.

  List<RoomEntity> _applyBookingFilter(
    // Apply booking filter.
    List<RoomEntity> rooms, // Input rooms.
    BookingFilter filter, // Selected filter.
  ) {
    // Start filter method.
    final now = DateTime.now(); // Current time.
    switch (filter) {
      // Switch by filter.
      case BookingFilter.all: // All rooms.
        return rooms; // Return all.
      case BookingFilter.occupied: // Occupied rooms.
        return rooms
            .where(
              (room) => _getBookingState(room, now) == BookingState.occupied,
            )
            .toList(); // Filter occupied.
      case BookingFilter.upcoming: // Upcoming rooms.
        return rooms
            .where(
              (room) => _getBookingState(room, now) == BookingState.upcoming,
            )
            .toList(); // Filter upcoming.
      case BookingFilter.empty: // Empty rooms.
        return rooms
            .where((room) => _getBookingState(room, now) == BookingState.empty)
            .toList(); // Filter empty.
    } // End switch.
  } // End _applyBookingFilter.
} // End _EmployeeRoomsViewState.

class _FloorTabData {
  // Define floor tab data.
  final int? value; // Floor value.
  final String label; // Tab label.
  final bool isAllFloors; // Whether tab is all floors.
  final bool isUnknownFloor; // Whether tab is unknown floors.

  const _FloorTabData({
    // Constructor.
    required this.value, // Floor value.
    required this.label, // Label.
    required this.isAllFloors, // All floors flag.
    required this.isUnknownFloor, // Unknown floors flag.
  }); // End constructor.

  const _FloorTabData.all() // Factory for all floors.
    : value = null, // Set value.
      label = 'Tất cả', // Set label.
      isAllFloors = true, // Set all floors.
      isUnknownFloor = false; // Set unknown flag.

  const _FloorTabData.unknown() // Factory for unknown floors.
    : value = null, // Set value.
      label = 'Chưa rõ tầng', // Set label.
      isAllFloors = false, // Set all floors.
      isUnknownFloor = true; // Set unknown.
} // End _FloorTabData.

class _FloorTabBar extends StatelessWidget {
  // Define floor tab bar.
  final List<_FloorTabData> floors; // Floor data list.

  const _FloorTabBar({required this.floors}); // Constructor.

  @override
  Widget build(BuildContext context) {
    // Build widget.
    return Container(
      // Wrap TabBar.
      color: AppColors.background, // Background color.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), // Padding.
      child: TabBar(
        // Build TabBar.
        isScrollable: true, // Allow horizontal scroll.
        indicatorColor: AppColors.primary, // Indicator color.
        labelColor: AppColors.primary, // Selected label color.
        unselectedLabelColor:
            AppColors.textSecondary, // Unselected label color.
        labelStyle: AppTextStyles.arimo(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ), // Label style.
        tabs: floors
            .map((floor) => Tab(text: floor.label))
            .toList(), // Build tabs.
      ), // End TabBar.
    ); // End Container.
  } // End build.
} // End _FloorTabBar.

class _BookingFilterBar extends StatelessWidget {
  // Define booking filter bar.
  final BookingFilter selectedFilter; // Current filter.
  final ValueChanged<BookingFilter> onSelected; // Callback for selection.

  const _BookingFilterBar({
    // Constructor.
    required this.selectedFilter, // Selected filter.
    required this.onSelected, // Selection callback.
  }); // End constructor.

  @override
  Widget build(BuildContext context) {
    // Build widget.
    return Padding(
      // Add padding.
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Padding value.
      child: Wrap(
        // Wrap chips.
        spacing: 8, // Horizontal spacing.
        runSpacing: 6, // Vertical spacing.
        children: [
          // Chip list.
          _FilterChip(
            // All chip.
            label: 'Tất cả', // Label.
            isSelected: selectedFilter == BookingFilter.all, // Selected.
            onTap: () => onSelected(BookingFilter.all), // On tap.
          ), // End chip.
          _FilterChip(
            // Occupied chip.
            label: 'Đang ở', // Label.
            isSelected: selectedFilter == BookingFilter.occupied, // Selected.
            onTap: () => onSelected(BookingFilter.occupied), // On tap.
            color: const Color(0xFFB45309), // Chip color.
          ), // End chip.
          _FilterChip(
            // Upcoming chip.
            label: 'Sắp tới', // Label.
            isSelected: selectedFilter == BookingFilter.upcoming, // Selected.
            onTap: () => onSelected(BookingFilter.upcoming), // On tap.
            color: const Color(0xFF2563EB), // Chip color.
          ), // End chip.
          _FilterChip(
            // Empty chip.
            label: 'Trống', // Label.
            isSelected: selectedFilter == BookingFilter.empty, // Selected.
            onTap: () => onSelected(BookingFilter.empty), // On tap.
            color: const Color(0xFF15803D), // Chip color.
          ), // End chip.
        ], // End chip list.
      ), // End Wrap.
    ); // End Padding.
  } // End build.
} // End _BookingFilterBar.

class _FilterChip extends StatelessWidget {
  // Define filter chip widget.
  final String label; // Chip label.
  final bool isSelected; // Selected flag.
  final VoidCallback onTap; // Tap callback.
  final Color? color; // Optional color.

  const _FilterChip({
    // Constructor.
    required this.label, // Label.
    required this.isSelected, // Selection.
    required this.onTap, // Tap callback.
    this.color, // Color.
  }); // End constructor.

  @override
  Widget build(BuildContext context) {
    // Build widget.
    final displayColor = color ?? AppColors.primary; // Determine color.
    return InkWell(
      // Build tap effect.
      onTap: onTap, // Handle tap.
      borderRadius: BorderRadius.circular(20), // Rounded corners.
      child: Container(
        // Chip container.
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ), // Padding.
        decoration: BoxDecoration(
          // Decoration.
          color: isSelected
              ? displayColor.withValues(alpha: 0.15)
              : Colors.white, // Background.
          borderRadius: BorderRadius.circular(20), // Border radius.
          border: Border.all(
            color: isSelected ? displayColor : AppColors.borderLight,
          ), // Border.
        ), // End decoration.
        child: Text(
          // Chip text.
          label, // Text label.
          style: AppTextStyles.arimo(
            // Text style.
            fontSize: 12, // Font size.
            fontWeight: FontWeight.w600, // Font weight.
            color: isSelected
                ? displayColor
                : AppColors.textSecondary, // Text color.
          ), // End style.
        ), // End Text.
      ), // End Container.
    ); // End InkWell.
  } // End build.
} // End _FilterChip.

class _RoomCard extends StatelessWidget {
  // Define room card.
  final RoomEntity room; // Room data.

  const _RoomCard({required this.room}); // Constructor.

  @override
  Widget build(BuildContext context) {
    // Build card.
    final bookingColor = _bookingStatusColor(room); // Booking status color.
    return Container(
      // Card container.
      padding: const EdgeInsets.all(14), // Padding.
      decoration: BoxDecoration(
        // Decoration.
        color: Colors.white, // Background.
        borderRadius: BorderRadius.circular(14), // Rounded corners.
        border: Border.all(color: AppColors.borderLight), // Border.
      ), // End decoration.
      child: Column(
        // Column layout.
        crossAxisAlignment: CrossAxisAlignment.start, // Align start.
        children: [
          // Children.
          Row(
            // First row.
            children: [
              // Row children.
              Expanded(
                // Expand name.
                child: Text(
                  // Room name.
                  room.name, // Name text.
                  style: AppTextStyles.arimo(
                    // Style.
                    fontSize: 16, // Font size.
                    fontWeight: FontWeight.w700, // Font weight.
                    color: AppColors.textPrimary, // Text color.
                  ), // End style.
                ), // End Text.
              ), // End Expanded.
              Container(
                // Booking status pill.
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ), // Padding.
                decoration: BoxDecoration(
                  // Decoration.
                  color: bookingColor.withValues(alpha: 0.12), // Background.
                  borderRadius: BorderRadius.circular(20), // Radius.
                ), // End decoration.
                child: Text(
                  // Booking status text.
                  _bookingStatusText(room), // Booking label.
                  style: AppTextStyles.arimo(
                    // Style.
                    fontSize: 12, // Font size.
                    fontWeight: FontWeight.w700, // Weight.
                    color: bookingColor, // Color.
                  ), // End style.
                ), // End Text.
              ), // End booking pill.
            ], // End row children.
          ), // End Row.
          const SizedBox(height: 8), // Spacing.
          Text('Loại phòng: ${room.roomTypeName}'), // Room type.
          Text('Tầng: ${room.floor?.toString() ?? 'Chưa cập nhật'}'), // Floor.
          Text(
            'Tình trạng phòng: ${room.status.displayText}',
          ), // Room status text.
          Text(
            'Hoạt động: ${room.isActive ? 'Có' : 'Không'}',
          ), // Active status.
        ], // End children.
      ), // End Column.
    ); // End Container.
  } // End build.

  Color _bookingStatusColor(RoomEntity room) {
    // Determine booking color.
    final state = _getBookingState(room, DateTime.now()); // Get booking state.
    switch (state) {
      case BookingState.occupied:
        return const Color(0xFFB45309); // Amber.
      case BookingState.upcoming:
        return const Color(0xFF2563EB); // Blue.
      case BookingState.empty:
        return const Color(0xFF15803D); // Green.
    }
  } // End _bookingStatusColor.

  String _bookingStatusText(RoomEntity room) {
    // Determine booking text.
    final state = _getBookingState(room, DateTime.now()); // Get booking state.
    switch (state) {
      case BookingState.occupied:
        return 'Đang ở';
      case BookingState.upcoming:
        return 'Sắp tới';
      case BookingState.empty:
        return 'Trống';
    }
  } // End _bookingStatusText.
} // End _RoomCard.
