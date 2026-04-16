// lib/features/employee/presentation/widgets/employee_scaffold.dart
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';  
import '../../../../../features/employee/shell/presentation/widgets/employee_fab.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_more_sheet.dart';
  
/// Khung Scaffold dùng chung cho các màn trong portal nhân viên.
/// Tự động set background và hiển thị nút "+" mở sheet More.
class EmployeeScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool showFab;

  const EmployeeScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.showFab = true,
  });

  @override
  State<EmployeeScaffold> createState() => _EmployeeScaffoldState();
}

class _EmployeeScaffoldState extends State<EmployeeScaffold> {
  Offset? _fabPosition;
  bool _isDragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fabPosition == null) {
      final size = MediaQuery.of(context).size;
      // Khởi tạo vị trí giống với mặc định của EndFloat
      _fabPosition = Offset(size.width - 80, size.height - 160);
    }
  }

  void _snapToEdge() {
    if (_fabPosition == null) return;
    final size = MediaQuery.of(context).size;
    const double fabLogicalWidth = 64.0;
    const double edgeMargin = 8.0;

    setState(() {
      _isDragging = false;
      // Nửa trái hay nửa phải màn hình
      if (_fabPosition!.dx + fabLogicalWidth / 2 < size.width / 2) {
        // Hít về lề trái
        _fabPosition = Offset(edgeMargin, _fabPosition!.dy);
      } else {
        // Hít về lề phải
        _fabPosition = Offset(size.width - fabLogicalWidth - edgeMargin, _fabPosition!.dy);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        children: [
          widget.body,
          if (widget.showFab && _fabPosition != null)
            AnimatedPositioned(
              duration: _isDragging ? Duration.zero : const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: _fabPosition!.dx,
              top: _fabPosition!.dy,
              child: GestureDetector(
                onPanStart: (_) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onPanUpdate: (details) {
                  final size = MediaQuery.of(context).size;
                  setState(() {
                    _fabPosition = Offset(
                      (_fabPosition!.dx + details.delta.dx)
                          .clamp(0.0, size.width - 64),
                      (_fabPosition!.dy + details.delta.dy)
                          .clamp(0.0, size.height - 120),
                    );
                  });
                },
                onPanEnd: (_) => _snapToEdge(),
                onPanCancel: _snapToEdge,
                child: EmployeeFab(
                  onTap: () => EmployeeMoreSheet.show(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

