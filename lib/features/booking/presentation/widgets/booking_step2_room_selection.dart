import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../employee/domain/entities/room_entity.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';

class BookingStep2RoomSelection extends StatefulWidget {
  final Function(int) onRoomSelected;

  const BookingStep2RoomSelection({
    super.key,
    required this.onRoomSelected,
  });

  @override
  State<BookingStep2RoomSelection> createState() =>
      _BookingStep2RoomSelectionState();
}

class _BookingStep2RoomSelectionState extends State<BookingStep2RoomSelection> {
  int? _selectedFloor;

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is BookingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48 * scale,
                  color: AppColors.red,
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

        // Get rooms and selected room ID from various states
        List<RoomEntity> rooms;
        int? selectedRoomId;

        if (state is BookingRoomsLoaded) {
          rooms = state.rooms;
          selectedRoomId = state.selectedRoomId;
        } else if (state is BookingSummaryReady) {
          // Đã có tóm tắt (đầy đủ thông tin) nhưng vẫn đang ở bước chọn phòng.
          // Tận dụng danh sách phòng đã load trong BookingBloc để tránh gọi API lại.
          final bloc = context.read<BookingBloc>();
          final cachedRooms = bloc.rooms;
          if (cachedRooms != null && cachedRooms.isNotEmpty) {
            rooms = cachedRooms;
            selectedRoomId = state.roomId;
          } else {
            // Chỉ khi chưa có cache mới gọi lại API
            selectedRoomId = state.roomId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<BookingBloc>().add(const BookingLoadRooms());
              }
            });
            return const Center(child: AppLoadingIndicator());
          }
        } else {
          // Nếu chưa load phòng lần nào, trigger load một lần
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(const BookingLoadRooms());
            }
          });
          return const Center(child: AppLoadingIndicator());
        }

        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hotel_outlined,
                  size: 64 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16 * scale),
                Text(
                  AppStrings.bookingNoRooms,
                  style: AppTextStyles.arimo(
                    fontSize: 16 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        // Group rooms by floor
        final Map<int?, List<RoomEntity>> roomsByFloor = {};
        for (final room in rooms) {
          final floor = room.floor;
          roomsByFloor.putIfAbsent(floor, () => <RoomEntity>[]).add(room);
        }

        // Sort floors
        final sortedFloors = roomsByFloor.keys.toList()
          ..sort((a, b) {
            if (a == null) return 1;
            if (b == null) return -1;
            return a.compareTo(b);
          });

        // Sort rooms inside each floor theo thứ tự số phòng tăng dần
        for (final entry in roomsByFloor.entries) {
          entry.value.sort((a, b) {
            final aNum = int.tryParse(a.name);
            final bNum = int.tryParse(b.name);
            if (aNum != null && bNum != null) {
              return aNum.compareTo(bNum);
            }
            return a.name.compareTo(b.name);
          });
        }

        if (sortedFloors.isEmpty) {
          return const SizedBox.shrink();
        }

        // Determine effective selected floor (keep previous selection if possible)
        final effectiveFloor = _selectedFloor ?? sortedFloors.first;
        final currentFloorRooms = roomsByFloor[effectiveFloor] ?? rooms;

        return Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.bookingRoom,
                style: AppTextStyles.tinos(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Chọn phòng trên sơ đồ từng tầng',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Floor selector (as horizontal chips)
              SizedBox(
                height: 40 * scale,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedFloors.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
                  itemBuilder: (context, index) {
                    final floor = sortedFloors[index];
                    final isSelectedFloor = floor == effectiveFloor;
                    final label = floor != null
                        ? '${AppStrings.bookingFloor} $floor'
                        : 'không rõ tầng';

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFloor = floor;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * scale,
                          vertical: 8 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: isSelectedFloor
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                            color: isSelectedFloor
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                          boxShadow: isSelectedFloor
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 10 * scale,
                                    offset: Offset(0, 3 * scale),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w600,
                              color: isSelectedFloor
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16 * scale),

              // Floor map container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 18 * scale,
                        offset: Offset(0, 6 * scale),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 20 * scale,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            effectiveFloor != null
                                ? 'Sơ đồ tầng $effectiveFloor'
                                : 'Sơ đồ phòng',
                            style: AppTextStyles.arimo(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          // Legend: Đang chọn (cam có tick) / Chưa chọn (ô tròn trắng)
                          _LegendSelected(scale: scale),
                          SizedBox(width: 16 * scale),
                          _LegendUnselected(scale: scale),
                        ],
                      ),
                      SizedBox(height: 16 * scale),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildTwoColumnMap(
                            context,
                            currentFloorRooms,
                            selectedRoomId,
                            scale,
                            onRoomTap: (room) {
                              widget.onRoomSelected(room.id);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildTwoColumnMap(
  BuildContext context,
  List<RoomEntity> rooms,
  int? selectedRoomId,
  double scale, {
  required void Function(RoomEntity room) onRoomTap,
}) {
  // Chia danh sách phòng thành 2 dãy lần lượt (ziczac) theo index
  final col1 = <RoomEntity>[];
  final col2 = <RoomEntity>[];

  for (var i = 0; i < rooms.length; i++) {
    if (i.isEven) {
      col1.add(rooms[i]);
    } else {
      col2.add(rooms[i]);
    }
  }

  Widget buildColumn(List<RoomEntity> columnRooms) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: columnRooms
          .map((room) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6 * scale),
                child: _RoomTile(
                  room: room,
                  isSelected: selectedRoomId == room.id,
                  onTap: () => onRoomTap(room),
                ),
              ))
          .toList(),
    );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(child: buildColumn(col1)),
      SizedBox(width: 12 * scale),
      Flexible(child: buildColumn(col2)),
    ],
  );
}

class _RoomTile extends StatelessWidget {
  final RoomEntity room;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoomTile({
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120 * scale,
        constraints: BoxConstraints(
          minHeight: 110 * scale,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
            ),
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row: icon + tầng
            Row(
              children: [
                Container(
                  width: 20 * scale,
                  height: 20 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6 * scale),
                  ),
                  child: Icon(
                    Icons.hotel,
                    size: 13 * scale,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: Text(
                    room.floor != null
                        ? '${AppStrings.bookingFloor} ${room.floor}'
                        : '',
                    style: AppTextStyles.arimo(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Container(
                  width: 16 * scale,
                  height: 16 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: 1.6,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 11 * scale,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 6 * scale),
            // Room name (center, to, rõ)
            Text(
              'Phòng ${room.name}',
              style: AppTextStyles.tinos(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4 * scale),
            // Room type (giới hạn chiều cao cố định để tránh overflow)
            SizedBox(
              height: 28 * scale,
              child: Center(
                child: Text(
                  room.roomTypeName,
                  style: AppTextStyles.arimo(
                    fontSize: 10 * scale,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendSelected extends StatelessWidget {
  final double scale;

  const _LegendSelected({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14 * scale,
          height: 14 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Icon(
            Icons.check,
            size: 9 * scale,
            color: AppColors.white,
          ),
        ),
        SizedBox(width: 6 * scale),
        Text(
          'Đang chọn',
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LegendUnselected extends StatelessWidget {
  final double scale;

  const _LegendUnselected({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14 * scale,
          height: 14 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.borderLight,
              width: 1.5,
            ),
          ),
        ),
        SizedBox(width: 6 * scale),
        Text(
          'Chưa chọn',
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
