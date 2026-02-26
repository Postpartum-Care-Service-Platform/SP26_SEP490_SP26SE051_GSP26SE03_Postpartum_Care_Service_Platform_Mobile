import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../auth/data/models/current_account_model.dart';
import 'services_formatters.dart';

class ResortKeyCard extends StatefulWidget {
  final NowPackageModel nowPackage;

  const ResortKeyCard({super.key, required this.nowPackage});

  @override
  State<ResortKeyCard> createState() => _ResortKeyCardState();
}

class _ResortKeyCardState extends State<ResortKeyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;
  int? _cachedRemainingDays;
  DateTime? _lastCalculationDate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _calculateRemainingDays();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSide() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTap: _toggleSide,
      child: SizedBox(
        height: 250 * scale,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * math.pi;
              final isUnder = angle > math.pi / 2;
              final displayFront = !isUnder;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: displayFront
                    ? _buildFront(context, scale)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildBack(context, scale),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Draft':
        return AppStrings.bookingStatusDraft;
      case 'Pending':
        return AppStrings.statusPending;
      case 'Confirmed':
        return AppStrings.bookingStatusConfirmed;
      case 'Cancelled':
        return AppStrings.statusCancelled;
      case 'Completed':
        return AppStrings.bookingStatusCompleted;
      default:
        return status;
    }
  }


  Widget _buildFront(BuildContext context, double scale) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 8 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22 * scale),
        child: Stack(
          children: [
            // SVG Keycard Background
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.keycard,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Package name overlay - Top
            Positioned(
              top: 80 * scale,
              left: 12 * scale,
              right: 68 * scale,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 10 * scale,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.servicesCurrentPackage,
                      style: AppTextStyles.arimo(
                        fontSize: 13.5 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.2,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.nowPackage.packageName,
                        style: AppTextStyles.tinos(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Status badge - Top right
            Positioned(
              bottom: 32  * scale,
              left: 22 * scale,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ],
                ),
                child: Text(
                  _getStatusLabel(widget.nowPackage.bookingStatus),
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Date range overlay - Bottom
            Positioned(
              bottom: 82 * scale,
              left: 0 * scale,
              right: 78 * scale,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 12 * scale,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Check-in date with login icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.login,
                          size: 16 * scale,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          formatDateLocal(widget.nowPackage.checkinDate),
                          style: AppTextStyles.arimo(
                            fontSize: 13.5 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10 * scale),
                    // Arrow separator
                    Icon(
                      Icons.double_arrow,
                      size: 16 * scale,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    SizedBox(width: 10 * scale),
                    // Check-out date with logout icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 16 * scale,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4 * scale),
                        Flexible(
                          child: Text(
                            formatDateLocal(widget.nowPackage.checkoutDate),
                            style: AppTextStyles.arimo(
                              fontSize: 13.5 * scale,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateRemainingDays() {
    final now = DateTime.now();
    // Only recalculate if it's a new day
    if (_lastCalculationDate != null &&
        _lastCalculationDate!.year == now.year &&
        _lastCalculationDate!.month == now.month &&
        _lastCalculationDate!.day == now.day) {
      return;
    }

    final nowPackage = widget.nowPackage;
    final totalNights = nowPackage.checkoutDate
        .difference(nowPackage.checkinDate)
        .inDays;
    final daysPassed = now.isBefore(nowPackage.checkinDate)
        ? 0
        : now.isAfter(nowPackage.checkoutDate)
        ? totalNights
        : now.difference(nowPackage.checkinDate).inDays;
    _cachedRemainingDays = (totalNights - daysPassed).clamp(0, totalNights);
    _lastCalculationDate = now;
  }

  Widget _buildBack(BuildContext context, double scale) {
    final nowPackage = widget.nowPackage;
    
    // Recalculate if needed (only once per day)
    _calculateRemainingDays();
    final remainingDays = _cachedRemainingDays ?? 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 8 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22 * scale),
        child: Stack(
          children: [
          // Subtle background gradient
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22 * scale),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.background.withValues(alpha: 0.25),
                      AppColors.white,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Decorative blobs
          Positioned(
            top: -30 * scale,
            right: -30 * scale,
            child: Container(
              width: 110 * scale,
              height: 110 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -40 * scale,
            left: -40 * scale,
            child: Container(
              width: 140 * scale,
              height: 140 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              16 * scale,
              16 * scale,
              16 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header + status badge
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(
                        Icons.meeting_room_outlined,
                        size: 16 * scale,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Expanded(
                      child: Text(
                        AppStrings.servicesBookingInfo,
                        style: AppTextStyles.tinos(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 7 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20 * scale),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8 * scale,
                            offset: Offset(0, 3 * scale),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timelapse_outlined,
                            size: 14 * scale,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6 * scale),
                          Text(
                            '$remainingDays ${AppStrings.bookingDays}',
                            style: AppTextStyles.arimo(
                              fontSize: 12.5 * scale,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14 * scale),

                // Info list (fixed height, no scroll needed for 3 rows)
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _InfoTile(
                        icon: Icons.confirmation_number_outlined,
                        label: AppStrings.servicesRoomNumber,
                        value: (nowPackage.roomName ?? '—').trim().isEmpty
                            ? '—'
                            : nowPackage.roomName!.trim(),
                        scale: scale,
                      ),
                      SizedBox(height: 10 * scale),
                      Divider(height: 1, color: AppColors.borderLight),
                      SizedBox(height: 10 * scale),
                      _InfoTile(
                        icon: Icons.bed_outlined,
                        label: AppStrings.bookingRoomType,
                        value: nowPackage.roomTypeName,
                        scale: scale,
                      ),
                      SizedBox(height: 10 * scale),
                      Divider(height: 1, color: AppColors.borderLight),
                      SizedBox(height: 10 * scale),
                      _InfoTile(
                        icon: Icons.layers_outlined,
                        label: AppStrings.servicesFloor,
                        value: nowPackage.floor?.toString() ?? '—',
                        scale: scale,
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
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double scale;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34 * scale,
          height: 34 * scale,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Icon(
            icon,
            size: 18 * scale,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 10 * scale),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 12.5 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 10 * scale),
        Text(
          value,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.arimo(
            fontSize: 12.5 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
