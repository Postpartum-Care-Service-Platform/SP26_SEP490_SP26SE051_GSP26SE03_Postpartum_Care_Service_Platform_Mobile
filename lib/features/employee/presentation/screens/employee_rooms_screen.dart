import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/room_status.dart';
import '../bloc/room/room_bloc.dart';
import '../bloc/room/room_event.dart';
import '../bloc/room/room_state.dart';

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

class _EmployeeRoomsView extends StatelessWidget {
  const _EmployeeRoomsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Phòng ở'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => context.read<RoomBloc>().add(const RefreshRooms()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading || state is RoomInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is RoomError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Không tải được danh sách phòng: ${state.message}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is RoomEmpty) {
            return const Center(child: Text('Hiện chưa có phòng nào.'));
          }

          if (state is RoomLoaded) {
            final rooms = [...state.rooms]
              ..sort((a, b) {
                final floorA = a.floor ?? -1;
                final floorB = b.floor ?? -1;
                if (floorA != floorB) return floorA.compareTo(floorB);
                return a.name.compareTo(b.name);
              });

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _RoomCard(room: rooms[index]),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomEntity room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(room.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  room.name,
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  room.status.displayText,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Loại phòng: ${room.roomTypeName}'),
          Text('Tầng: ${room.floor?.toString() ?? 'Chưa cập nhật'}'),
          Text('Hoạt động: ${room.isActive ? 'Có' : 'Không'}'),
        ],
      ),
    );
  }

  Color _statusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return const Color(0xFF15803D);
      case RoomStatus.occupied:
        return const Color(0xFFB45309);
      case RoomStatus.maintenance:
        return const Color(0xFF2563EB);
      case RoomStatus.inactive:
        return const Color(0xFF6B7280);
    }
  }
}
