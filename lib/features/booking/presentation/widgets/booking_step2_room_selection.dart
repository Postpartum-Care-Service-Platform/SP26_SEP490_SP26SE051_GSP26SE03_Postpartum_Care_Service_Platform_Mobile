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

class BookingStep2RoomSelection extends StatelessWidget {
  final Function(int) onRoomSelected;

  const BookingStep2RoomSelection({
    super.key,
    required this.onRoomSelected,
  });

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
          // If we have summary, we need to load rooms again
          // But we can get selected room ID from summary
          selectedRoomId = state.roomId;
          // Trigger room load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(const BookingLoadRooms());
            }
          });
          return const Center(child: AppLoadingIndicator());
        } else {
          // If state is not BookingRoomsLoaded, trigger load
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
          if (!roomsByFloor.containsKey(floor)) {
            roomsByFloor[floor] = [];
          }
          roomsByFloor[floor]!.add(room);
        }

        // Sort floors
        final sortedFloors = roomsByFloor.keys.toList()
          ..sort((a, b) {
            if (a == null) return 1;
            if (b == null) return -1;
            return a.compareTo(b);
          });

        return ListView.builder(
          padding: EdgeInsets.all(16 * scale),
          itemCount: sortedFloors.length,
          itemBuilder: (context, floorIndex) {
            final floor = sortedFloors[floorIndex];
            final floorRooms = roomsByFloor[floor]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Floor header
                Padding(
                  padding: EdgeInsets.only(bottom: 12 * scale),
                  child: Row(
                    children: [
                      Icon(
                        Icons.layers,
                        size: 18 * scale,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        floor != null
                            ? '${AppStrings.bookingFloor} $floor'
                            : 'Không xác định tầng',
                        style: AppTextStyles.arimo(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rooms grid for this floor
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12 * scale,
                    mainAxisSpacing: 12 * scale,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: floorRooms.length,
                  itemBuilder: (context, roomIndex) {
                    final room = floorRooms[roomIndex];
                    final isSelected = selectedRoomId == room.id;

                    return _RoomCard(
                      room: room,
                      isSelected: isSelected,
                      onTap: () {
                        onRoomSelected(room.id);
                      },
                    );
                  },
                ),
                SizedBox(height: 24 * scale),
              ],
            );
          },
        );
      },
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomEntity room;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoomCard({
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
        padding: EdgeInsets.all(10 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Room icon
            Container(
              width: 40 * scale,
              height: 40 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Icon(
                Icons.hotel,
                size: 20 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8 * scale),
            // Room name
            Text(
              'Phòng ${room.name}',
              style: AppTextStyles.tinos(
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4 * scale),
            // Room type
            Flexible(
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
            SizedBox(height: 6 * scale),
            // Selection indicator
            Container(
              width: 20 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderLight,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14 * scale,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
