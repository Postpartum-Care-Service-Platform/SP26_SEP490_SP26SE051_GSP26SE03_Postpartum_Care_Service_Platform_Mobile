import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../contract/data/datasources/contract_remote_datasource.dart';
import '../../../contract/data/models/contract_model.dart';
import 'staff_contract_preview_screen.dart';

/// Màn hình staff quản lý hợp đồng cho một booking cụ thể.
class StaffContractScreen extends StatefulWidget {
  final BookingModel? booking;
  final ContractModel? initialContract;

  const StaffContractScreen({super.key, this.booking, this.initialContract});

  /// Convenience constructor khi đã có sẵn ContractModel (từ danh sách hợp đồng)
  factory StaffContractScreen.fromContract(ContractModel contract) {
    return StaffContractScreen(booking: null, initialContract: contract);
  }

  @override
  State<StaffContractScreen> createState() => _StaffContractScreenState();
}

class _StaffContractScreenState extends State<StaffContractScreen> {
  final _remote = ContractRemoteDataSourceImpl(dio: ApiClient.dio);

  ContractModel? _contract;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (widget.initialContract != null) {
        // Nếu đã có sẵn contract (từ danh sách), ưu tiên load lại theo ID
        final loaded = await _remote.getContractById(
          widget.initialContract!.id,
        );
        if (!mounted) return;
        setState(() {
          _contract = loaded;
        });
      } else if (widget.booking?.contract != null) {
        // Booking đã có hợp đồng -> lấy chi tiết theo ID để cập nhật mới nhất
        final id = widget.booking!.contract!.id;
        final loaded = await _remote.getContractById(id);
        if (!mounted) return;
        setState(() {
          _contract = loaded;
        });
      } else if (widget.booking != null) {
        // Chưa có hợp đồng -> tạo tự động từ booking
        final created = await _remote.createContractFromBooking(
          widget.booking!.id,
        );
        if (!mounted) return;
        setState(() {
          _contract = created;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFF6B7280); // Gray
      case 'sent':
        return const Color(0xFF2563EB); // Blue
      case 'signed':
        return const Color(0xFF16A34A); // Green
      case 'cancelled':
        return const Color(0xFFDC2626); // Red
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Nháp';
      case 'sent':
        return 'Đã gửi';
      case 'signed':
        return 'Đã ký';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Future<void> _downloadPdf() async {
    final contract = _contract;
    if (contract == null) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await _remote.exportContractPdf(contract.id);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/contract_${contract.id}.pdf');
      await file.writeAsBytes(bytes);

      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        AppToast.showSuccess(context, message: 'Đã tải hợp đồng thành công');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, message: 'Không thể tải hợp đồng: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendContract() async {
    final contract = _contract;
    if (contract == null) return;

    setState(() {
      _isSending = true;
    });
    try {
      final message = await _remote.sendContract(contract.id);
      if (mounted) {
        AppToast.showSuccess(context, message: message);
      }
      // reload trạng thái sau khi gửi
      final updated = await _remote.getContractById(contract.id);
      if (mounted) {
        setState(() {
          _contract = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, message: 'Không thể gửi hợp đồng: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _openPreview() {
    final bookingId = widget.booking?.id ?? _contract?.bookingId;
    if (bookingId == null) {
      AppToast.showError(
        context,
        message: 'Không tìm thấy booking để preview hợp đồng',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StaffContractPreviewScreen(bookingId: bookingId),
      ),
    );
  }

  Future<void> _showUploadSignedSheet() async {
    final contract = _contract;
    if (contract == null) return;

    DateTime signedDate = contract.signedDate ?? DateTime.now();
    final picker = ImagePicker();
    String? pickedImagePath;
    bool isUploading = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final scale = AppResponsive.scaleFactor(ctx);
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20 * scale,
              right: 20 * scale,
              top: 20 * scale,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20 * scale,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40 * scale,
                        height: 4 * scale,
                        margin: EdgeInsets.only(bottom: 20 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2 * scale),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Icon(
                            Icons.cloud_upload_rounded,
                            color: const Color(0xFF0EA5E9),
                            size: 24 * scale,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload hợp đồng đã ký',
                                style: AppTextStyles.arimo(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                'Chọn ảnh hợp đồng đã ký từ camera hoặc thư viện',
                                style: AppTextStyles.arimo(
                                  fontSize: 13 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 20 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: _ImagePickerButton(
                          icon: Icons.photo_camera_rounded,
                          label: 'Chụp ảnh',
                          color: const Color(0xFF0EA5E9),
                          onPressed: isUploading
                              ? null
                              : () async {
                                  final image = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 85,
                                    maxWidth: 1600,
                                  );
                                  if (image != null) {
                                    setModalState(() {
                                      pickedImagePath = image.path;
                                    });
                                  }
                                },
                          scale: scale,
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: _ImagePickerButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Thư viện',
                          color: const Color(0xFF7C3AED),
                          onPressed: isUploading
                              ? null
                              : () async {
                                  final image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 85,
                                    maxWidth: 1600,
                                  );
                                  if (image != null) {
                                    setModalState(() {
                                      pickedImagePath = image.path;
                                    });
                                  }
                                },
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                        color: pickedImagePath != null
                            ? const Color(0xFF0EA5E9).withValues(alpha: 0.3)
                            : AppColors.borderLight,
                        width: pickedImagePath != null ? 2 : 1,
                      ),
                      color: pickedImagePath != null
                          ? const Color(0xFF0EA5E9).withValues(alpha: 0.05)
                          : AppColors.background,
                    ),
                    child: pickedImagePath == null
                        ? Row(
                            children: [
                              const Icon(Icons.image_outlined),
                              SizedBox(width: 10 * scale),
                              Expanded(
                                child: Text(
                                  'Chưa chọn ảnh',
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      color: AppColors.verified),
                                  SizedBox(width: 10 * scale),
                                  Expanded(
                                    child: Text(
                                      'Đã chọn ảnh',
                                      style: AppTextStyles.arimo(
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: isUploading
                                        ? null
                                        : () {
                                            setModalState(() {
                                              pickedImagePath = null;
                                            });
                                          },
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * scale),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10 * scale),
                                child: Image.file(
                                  File(pickedImagePath!),
                                  height: 180 * scale,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 180 * scale,
                                    color: AppColors.background,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Không thể hiển thị ảnh',
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: 20 * scale),
                  Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ngày ký hợp đồng',
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                _formatDate(signedDate),
                                style: AppTextStyles.arimo(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: signedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() => signedDate = picked);
                            }
                          },
                          icon: Icon(Icons.edit_rounded, size: 16 * scale),
                          label: const Text('Chọn'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              if (pickedImagePath == null) {
                                AppToast.showError(
                                  context,
                                  message: 'Vui lòng chọn/chụp ảnh hợp đồng đã ký',
                                );
                                return;
                              }

                              setModalState(() => isUploading = true);
                              try {
                                final message = await _remote.uploadSignedFile(
                                  id: contract.id,
                                  filePath: pickedImagePath!,
                                  signedDate: signedDate,
                                );
                                if (!mounted) return;
                                Navigator.of(ctx).pop();
                                AppToast.showSuccess(context, message: message);
                                final updated =
                                    await _remote.getContractById(contract.id);
                                if (!mounted) return;
                                setState(() {
                                  _contract = updated;
                                });
                              } catch (e) {
                                if (mounted) {
                                  AppToast.showError(
                                    context,
                                    message:
                                        'Không thể upload hợp đồng đã ký: $e',
                                  );
                                }
                                setModalState(() => isUploading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        elevation: 2,
                      ),
                      icon: Icon(
                        isUploading ? Icons.hourglass_empty : Icons.check_rounded,
                        size: 20 * scale,
                      ),
                      label: Text(
                        isUploading ? 'Đang upload...' : 'Lưu và upload',
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          ),
        );
      },
    );
  }

  Future<void> _showEditContentSheet() async {
    final contract = _contract;
    if (contract == null) return;

    final totalController = TextEditingController();
    final discountController = TextEditingController();
    final finalController = TextEditingController();

    DateTime? effectiveFrom = contract.effectiveFrom;
    DateTime? effectiveTo = contract.effectiveTo;
    DateTime? checkinDate = contract.checkinDate;
    DateTime? checkoutDate = contract.checkoutDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final scale = AppResponsive.scaleFactor(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16 * scale,
            right: 16 * scale,
            top: 16 * scale,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16 * scale,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Widget _dateRow(
                String label,
                DateTime? value,
                ValueChanged<DateTime?> onChanged,
              ) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$label: ${value != null ? _formatDate(value) : '-'}',
                        style: AppTextStyles.arimo(fontSize: 13 * scale),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final initial = value ?? DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        setModalState(() => onChanged(picked));
                      },
                      child: const Text('Chọn'),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chỉnh sửa nội dung hợp đồng',
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    _dateRow('Hiệu lực từ', effectiveFrom, (v) {
                      effectiveFrom = v;
                    }),
                    _dateRow('Hiệu lực đến', effectiveTo, (v) {
                      effectiveTo = v;
                    }),
                    _dateRow('Check-in', checkinDate, (v) {
                      checkinDate = v;
                    }),
                    _dateRow('Check-out', checkoutDate, (v) {
                      checkoutDate = v;
                    }),
                    SizedBox(height: 12 * scale),
                    TextField(
                      controller: totalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Tổng tiền (VNĐ, để trống nếu giữ nguyên)',
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    TextField(
                      controller: discountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Giảm giá (VNĐ, để trống nếu giữ nguyên)',
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    TextField(
                      controller: finalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Thành tiền (VNĐ, để trống nếu giữ nguyên)',
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          double? _parse(String text) {
                            if (text.trim().isEmpty) return null;
                            return double.tryParse(
                              text.trim().replaceAll(',', ''),
                            );
                          }

                          Navigator.of(ctx).pop();
                          try {
                            final updated = await _remote.updateContent(
                              contract.id,
                              effectiveFrom: effectiveFrom,
                              effectiveTo: effectiveTo,
                              checkinDate: checkinDate,
                              checkoutDate: checkoutDate,
                              totalPrice: _parse(totalController.text),
                              discountAmount: _parse(discountController.text),
                              finalAmount: _parse(finalController.text),
                            );
                            if (mounted) {
                              AppToast.showSuccess(
                                context,
                                message: 'Cập nhật hợp đồng thành công',
                              );
                              setState(() {
                                _contract = updated;
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              AppToast.showError(
                                context,
                                message: 'Không thể cập nhật hợp đồng: $e',
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Lưu thay đổi'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Hợp đồng dịch vụ',
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: _buildBody(scale),
      ),
    );
  }

  Widget _buildBody(double scale) {
    if (_isLoading && _contract == null && _error == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64 * scale, color: AppColors.red),
            SizedBox(height: 16 * scale),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24 * scale),
            ElevatedButton(
              onPressed: _init,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final contract = _contract;
    if (contract == null) {
      return Center(
        child: Text(
          'Không tìm thấy hợp đồng.',
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card với mã hợp đồng và status
          Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã hợp đồng',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6 * scale),
                          Text(
                            contract.contractCode,
                            style: AppTextStyles.tinos(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                        vertical: 8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(contract.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20 * scale),
                        border: Border.all(
                          color: _statusColor(contract.status).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8 * scale,
                            height: 8 * scale,
                            decoration: BoxDecoration(
                              color: _statusColor(contract.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Text(
                            _statusText(contract.status),
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w700,
                              color: _statusColor(contract.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
          // Thông tin chi tiết hợp đồng
          Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      'Thông tin hợp đồng',
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Ngày hợp đồng',
                  value: _formatDate(contract.contractDate),
                  scale: scale,
                ),
                SizedBox(height: 16 * scale),
                _InfoRow(
                  icon: Icons.event_available_rounded,
                  label: 'Hiệu lực từ',
                  value: _formatDate(contract.effectiveFrom),
                  scale: scale,
                ),
                SizedBox(height: 16 * scale),
                _InfoRow(
                  icon: Icons.event_busy_rounded,
                  label: 'Hiệu lực đến',
                  value: _formatDate(contract.effectiveTo),
                  scale: scale,
                ),
                if (contract.signedDate != null) ...[
                  SizedBox(height: 16 * scale),
                  _InfoRow(
                    icon: Icons.edit_document,
                    label: 'Ngày ký',
                    value: _formatDate(contract.signedDate!),
                    scale: scale,
                    highlight: true,
                  ),
                ],
                SizedBox(height: 16 * scale),
                Divider(height: 1, color: AppColors.borderLight),
                SizedBox(height: 16 * scale),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Khách hàng',
                  value:
                      contract.customer?.username ??
                      contract.customer?.email ??
                      'N/A',
                  scale: scale,
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          // Actions Section
          Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 20 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      'Thao tác',
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                // Primary actions
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.picture_as_pdf_rounded,
                        label: _isLoading ? 'Đang tải...' : 'Xuất PDF',
                        color: AppColors.primary,
                        onPressed: _isLoading ? null : _downloadPdf,
                        scale: scale,
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.send_rounded,
                        label: _isSending ? 'Đang gửi...' : 'Gửi khách',
                        color: const Color(0xFF2563EB),
                        onPressed: _isSending ? null : _sendContract,
                        scale: scale,
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                _ActionButton(
                  icon: Icons.visibility_rounded,
                  label: 'Xem trước hợp đồng',
                  color: const Color(0xFF0284C7),
                  onPressed: _openPreview,
                  scale: scale,
                  isOutlined: true,
                  isFullWidth: true,
                ),
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.cloud_upload_rounded,
                        label: 'Upload đã ký',
                        color: const Color(0xFF0EA5E9),
                        onPressed: _showUploadSignedSheet,
                        scale: scale,
                        isOutlined: true,
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.edit_note_rounded,
                        label: 'Chỉnh sửa',
                        color: const Color(0xFF7C3AED),
                        onPressed: _showEditContentSheet,
                        scale: scale,
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double scale;
  final bool highlight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scale,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: highlight
          ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              icon,
              size: 18 * scale,
              color: highlight ? AppColors.primary : AppColors.textSecondary,
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
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  value,
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: highlight ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final double scale;
  final bool isOutlined;
  final bool isFullWidth;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    required this.scale,
    this.isOutlined = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color, width: 1.5),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 14 * scale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scale),
              ),
            ),
            icon: Icon(icon, size: 20 * scale),
            label: Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 14 * scale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              elevation: 2,
            ),
            icon: Icon(icon, size: 20 * scale),
            label: Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _ImagePickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final double scale;

  const _ImagePickerButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: 16 * scale),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scale),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28 * scale),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
