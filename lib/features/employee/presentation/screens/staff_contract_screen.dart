import 'dart:io';

import 'package:flutter/material.dart';
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
        return AppColors.textSecondary;
      case 'signed':
        return AppColors.verified;
      default:
        return AppColors.textSecondary;
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

    final fileController = TextEditingController(text: contract.fileUrl ?? '');
    DateTime signedDate = contract.signedDate ?? DateTime.now();

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
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload hợp đồng đã ký',
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  TextField(
                    controller: fileController,
                    decoration: InputDecoration(
                      labelText: 'Link file hợp đồng (PDF)',
                      hintText: 'Nhập URL hoặc đường dẫn file PDF đã ký',
                      helperText: 'Ví dụ: https://example.com/contract.pdf hoặc file:///path/to/contract.pdf',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 12 * scale),
                  Row(
                    children: [
                      Text(
                        'Ngày ký: ${_formatDate(signedDate)}',
                        style: AppTextStyles.arimo(fontSize: 13 * scale),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
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
                        child: const Text('Chọn ngày'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final url = fileController.text.trim();
                        if (url.isEmpty) {
                          AppToast.showError(
                            context,
                            message: 'Vui lòng nhập link file hợp đồng',
                          );
                          return;
                        }
                        Navigator.of(ctx).pop();
                        try {
                          final message = await _remote.uploadSigned(
                            id: contract.id,
                            fileUrl: url,
                            signedDate: signedDate,
                          );
                          if (mounted) {
                            AppToast.showSuccess(context, message: message);
                            final updated = await _remote.getContractById(
                              contract.id,
                            );
                            setState(() {
                              _contract = updated;
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            AppToast.showError(
                              context,
                              message: 'Không thể upload hợp đồng đã ký: $e',
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              );
            },
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
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            contract.contractCode,
                            style: AppTextStyles.tinos(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 6 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          contract.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: Text(
                        contract.status,
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(contract.status),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * scale),
                Divider(height: 1, color: AppColors.borderLight),
                SizedBox(height: 16 * scale),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Ngày hợp đồng',
                  value: _formatDate(contract.contractDate),
                  scale: scale,
                ),
                SizedBox(height: 12 * scale),
                _InfoRow(
                  icon: Icons.event_available_rounded,
                  label: 'Hiệu lực từ',
                  value: _formatDate(contract.effectiveFrom),
                  scale: scale,
                ),
                SizedBox(height: 12 * scale),
                _InfoRow(
                  icon: Icons.event_busy_rounded,
                  label: 'Hiệu lực đến',
                  value: _formatDate(contract.effectiveTo),
                  scale: scale,
                ),
                if (contract.signedDate != null) ...[
                  SizedBox(height: 12 * scale),
                  _InfoRow(
                    icon: Icons.edit_document,
                    label: 'Ngày ký',
                    value: _formatDate(contract.signedDate!),
                    scale: scale,
                  ),
                ],
                SizedBox(height: 12 * scale),
                _InfoRow(
                  icon: Icons.person_outline,
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _downloadPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(_isLoading ? 'Đang tải...' : 'Xuất PDF'),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSending ? null : _sendContract,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  icon: const Icon(Icons.send_outlined),
                  label: Text(_isSending ? 'Đang gửi...' : 'Gửi cho khách'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openPreview,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0284C7),
                side: const BorderSide(color: Color(0xFF0284C7)),
              ),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Preview hợp đồng (draft)'),
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showUploadSignedSheet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0EA5E9),
                    side: const BorderSide(color: Color(0xFF0EA5E9)),
                  ),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Upload hợp đồng đã ký'),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showEditContentSheet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C3AED),
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                  ),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Chỉnh sửa nội dung'),
                ),
              ),
            ],
          ),
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18 * scale, color: AppColors.textSecondary),
        SizedBox(width: 8 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                value,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
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
