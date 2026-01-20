import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/booking_entity.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final String Function(double) formatPrice;
  final String Function(DateTime) formatDate;
  final String Function(String) getStatusLabel;
  final Color Function(String) getStatusColor;
  final VoidCallback onTap;

  static const double _headerHeightBase = 92.0;
  static const double _notchHeightBase = 20.0;

  const BookingCard({
    super.key,
    required this.booking,
    required this.formatPrice,
    required this.formatDate,
    required this.getStatusLabel,
    required this.getStatusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final headerHeight = _headerHeightBase * scale;
    final notchHeight = _notchHeightBase * scale;
    final notchRadius = notchHeight / 2;
    final notchCenterY = headerHeight + (notchHeight / 2);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16 * scale),
        child: PhysicalShape(
          color: AppColors.white,
          elevation: 6 * scale,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          clipper: _BoardingPassClipper(
            borderRadius: 16 * scale,
            notchCenterY: notchCenterY,
            notchRadius: notchRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            foregroundPainter: _BoardingPassBorderPainter(
              borderRadius: 16 * scale,
              notchCenterY: notchCenterY,
              notchRadius: notchRadius,
              strokeWidth: 2 * scale,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
            child: Column(
              children: [
                // Header section với màu primary
                _BoardingPassHeader(
                  bookingId: booking.id,
                  status: booking.status,
                  getStatusLabel: getStatusLabel,
                  getStatusColor: getStatusColor,
                  height: headerHeight,
                ),

                // Perforated edge effect
                _PerforatedEdge(height: notchHeight),

                // Main content section
                Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date section - Check-in và Check-out như Departure/Arrival
                      _DateSection(
                        startDate: booking.startDate,
                        endDate: booking.endDate,
                        formatDate: formatDate,
                      ),

                      SizedBox(height: 20 * scale),

                      // Package và Room info cùng một dòng
                      if (booking.package != null || booking.room != null)
                        _PackageRoomRow(
                          packageName: booking.package?.packageName,
                          roomName: booking.room?.name,
                          roomFloor: booking.room?.floor,
                        ),

                      SizedBox(height: 20 * scale),

                      // Price section
                      _PriceSection(
                        finalAmount: booking.finalAmount,
                        paidAmount: booking.paidAmount,
                        remainingAmount: booking.remainingAmount,
                        formatPrice: formatPrice,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardingPassHeader extends StatelessWidget {
  final int bookingId;
  final String status;
  final String Function(String) getStatusLabel;
  final Color Function(String) getStatusColor;
  final double height;

  const _BoardingPassHeader({
    required this.bookingId,
    required this.status,
    required this.getStatusLabel,
    required this.getStatusColor,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return SizedBox(
      height: height,
      child: Container(
        padding: EdgeInsets.all(20 * scale),
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MÃ ĐẶT PHÒNG',
                  style: AppTextStyles.arimo(
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '#$bookingId',
                  style: AppTextStyles.tinos(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Text(
                getStatusLabel(status).toUpperCase(),
                style: AppTextStyles.arimo(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: getStatusColor(status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerforatedEdge extends StatelessWidget {
  final double height;

  const _PerforatedEdge({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _PerforatedEdgePainter(),
      ),
    );
  }
}

class _PerforatedEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dashWidth = 8.0;
    final dashSpace = 6.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BoardingPassClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double notchCenterY;
  final double notchRadius;

  const _BoardingPassClipper({
    required this.borderRadius,
    required this.notchCenterY,
    required this.notchRadius,
  });

  @override
  Path getClip(Size size) {
    final r = borderRadius.clamp(0.0, size.shortestSide / 2).toDouble();
    final notchR =
        notchRadius.clamp(0.0, size.shortestSide / 2).toDouble();
    final y = notchCenterY.clamp(notchR, size.height - notchR).toDouble();

    // Base rounded-rect
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(r),
        ),
      );

    // Cut 2 semicircle notches from left & right edges
    final notches = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(0, y),
          radius: notchR,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, y),
          radius: notchR,
        ),
      );

    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  bool shouldReclip(covariant _BoardingPassClipper oldClipper) {
    return oldClipper.borderRadius != borderRadius ||
        oldClipper.notchCenterY != notchCenterY ||
        oldClipper.notchRadius != notchRadius;
  }
}

class _BoardingPassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double notchCenterY;
  final double notchRadius;
  final double strokeWidth;
  final Color color;

  const _BoardingPassBorderPainter({
    required this.borderRadius,
    required this.notchCenterY,
    required this.notchRadius,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _BoardingPassClipper(
      borderRadius: borderRadius,
      notchCenterY: notchCenterY,
      notchRadius: notchRadius,
    ).getClip(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BoardingPassBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.notchCenterY != notchCenterY ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}

class _DateSection extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String Function(DateTime) formatDate;

  const _DateSection({
    required this.startDate,
    required this.endDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _DateColumn(
              label: 'CHECK-IN',
              date: startDate,
              formatDate: formatDate,
              icon: Icons.login_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 60 * scale,
            color: AppColors.borderLight,
          ),
          Expanded(
            child: _DateColumn(
              label: 'CHECK-OUT',
              date: endDate,
              formatDate: formatDate,
              icon: Icons.logout_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;
  final String Function(DateTime) formatDate;
  final IconData icon;

  const _DateColumn({
    required this.label,
    required this.date,
    required this.formatDate,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final dateStr = formatDate(date);

    return Column(
      children: [
        Icon(
          icon,
          size: 20 * scale,
          color: AppColors.primary,
        ),
        SizedBox(height: 8 * scale),
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 9 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          dateStr,
          style: AppTextStyles.tinos(
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoSection({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Icon(
            icon,
            size: 18 * scale,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 10 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                value,
                style: AppTextStyles.tinos(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageRoomRow extends StatelessWidget {
  final String? packageName;
  final String? roomName;
  final int? roomFloor;

  const _PackageRoomRow({
    this.packageName,
    this.roomName,
    this.roomFloor,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        if (packageName != null) ...[
          Expanded(
            child: _InfoSection(
              label: 'Gói dịch vụ',
              value: packageName!,
              icon: Icons.bed_rounded,
            ),
          ),
          if (roomName != null) SizedBox(width: 12 * scale),
        ],
        if (roomName != null)
          Expanded(
            child: _InfoSection(
              label: 'Phòng',
              value: '$roomName${roomFloor != null ? ' - Tầng $roomFloor' : ''}',
              icon: Icons.business_rounded,
            ),
          ),
      ],
    );
  }
}

class _PriceSection extends StatelessWidget {
  final double finalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String Function(double) formatPrice;

  const _PriceSection({
    required this.finalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THÀNH TIỀN',
                    style: AppTextStyles.arimo(
                      fontSize: 9 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    formatPrice(finalAmount),
                    style: AppTextStyles.tinos(
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ĐÃ THANH TOÁN',
                    style: AppTextStyles.arimo(
                      fontSize: 9 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    formatPrice(paidAmount),
                    style: AppTextStyles.tinos(
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verified,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (remainingAmount > 0) ...[
            SizedBox(height: 16 * scale),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Còn lại',
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    formatPrice(remainingAmount),
                    style: AppTextStyles.tinos(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
}
