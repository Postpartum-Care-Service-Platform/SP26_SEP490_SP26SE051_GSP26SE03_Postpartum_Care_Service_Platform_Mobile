import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../../../../features/booking/data/models/booking_model.dart';
import '../../../../../features/booking/data/models/customer_model.dart';
import '../../../../../features/contract/data/datasources/contract_remote_datasource.dart';
import '../../../../../features/contract/data/models/contract_model.dart';
import '../../../../../features/employee/contract/presentation/screens/staff_contract_preview_screen.dart';

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
  final _bookingRemote = BookingRemoteDataSourceImpl();

  ContractModel? _contract;
  /// Customer fetched from /api/Booking/{id} when contract.customer is null
  CustomerModel? _bookingCustomer;
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
      // Nếu contract.customer == null, fetch booking để lấy thông tin khách hàng
      await _fetchBookingCustomerIfNeeded();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Nếu hợp đồng không có customer, gọi /api/Booking/{bookingId} để lấy thông tin khách.
  Future<void> _fetchBookingCustomerIfNeeded() async {
    final contract = _contract;
    if (contract == null) return;
    // Đã có customer từ contract — không cần fetch thêm
    if (contract.customer != null) return;

    final bookingId = contract.bookingId;

    try {
      final booking = await _bookingRemote.getBookingById(bookingId);
      if (!mounted) return;
      if (booking.customer != null) {
        setState(() {
          _bookingCustomer = booking.customer;
        });
      }
    } catch (_) {
      // Không làm gián đoạn UI nếu fetch booking thất bại
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
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
      case 'printed':
        return const Color(0xFF2563EB); // Blue
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
      case 'printed':
        return 'Đã in';
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
      // Use external storage directory so users can find the file more easily on Android
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/contract_${contract.id}.pdf');
      await file.writeAsBytes(bytes);

      // Open the file using open_filex instead of url_launcher to avoid FileUriExposedException
      final result = await OpenFilex.open(file.path);
      
      if (result.type != ResultType.done && mounted) {
        AppToast.showError(
          context,
          message: 'Không thể mở file: ${result.message}',
        );
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
        message: 'Không tìm thấy booking để xem nội dung hợp đồng (HTML)',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StaffContractPreviewScreen(bookingId: bookingId),
      ),
    );
  }

  void _openSignedContractImage() {
    final contract = _contract;
    if (contract == null) return;
    
    List<String> imageUrls = [];
    if (contract.images != null && contract.images!.isNotEmpty) {
      imageUrls = contract.images!;
    } else if (contract.fileUrl != null && contract.fileUrl!.trim().isNotEmpty) {
      imageUrls = contract.fileUrl!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    if (imageUrls.isEmpty) {
      AppToast.showError(
        context,
        message: 'Chưa có hợp đồng đã ký để xem',
      );
      return;
    }

    imageUrls = imageUrls.map((url) {
      String fullUrl = url;
      if (!fullUrl.startsWith('http')) {
        final baseUrl = AppConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
        fullUrl = '$baseUrl${fullUrl.startsWith('/') ? '' : '/'}$fullUrl';
      }
      return fullUrl;
    }).toList();

    final firstUrl = imageUrls.first;
    final isImageUrl = RegExp(
      r'\.(png|jpe?g|gif|webp|bmp)(\?|$)',
      caseSensitive: false,
    ).hasMatch(firstUrl) || firstUrl.contains('image/upload');

    if (!isImageUrl) {
      _openSignedContractLink(firstUrl);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final scale = AppResponsive.scaleFactor(ctx);
        int currentIndex = 0;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.all(16 * scale),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
              child: SizedBox(
                height: 550 * scale, // Fixed height to provide constraints for Flexible
                child: Padding(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6 * scale),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.image_rounded,
                                color: AppColors.primary,
                                size: 18 * scale,
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Hợp đồng đã ký',
                              style: AppTextStyles.arimo(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                          splashRadius: 20 * scale,
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * scale),
                    Flexible(
                      child: AspectRatio(
                        aspectRatio: 0.7, 
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12 * scale),
                          child: Container(
                            color: AppColors.background,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  itemCount: imageUrls.length,
                                  onPageChanged: (idx) {
                                    setDialogState(() => currentIndex = idx);
                                  },
                                  itemBuilder: (context, index) {
                                    return InteractiveViewer(
                                      minScale: 1.0,
                                      maxScale: 5.0,
                                      child: Image.network(
                                        imageUrls[index],
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              color: AppColors.primary,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.broken_image_outlined, size: 48 * scale, color: AppColors.textSecondary),
                                                SizedBox(height: 8 * scale),
                                                Text(
                                                  'Không thể tải ảnh #${index + 1}',
                                                  style: AppTextStyles.arimo(
                                                    fontSize: 12 * scale,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                if (imageUrls.length > 1)
                                  Positioned(
                                    top: 12 * scale,
                                    right: 12 * scale,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(20 * scale),
                                      ),
                                      child: Text(
                                        '${currentIndex + 1} / ${imageUrls.length}',
                                        style: AppTextStyles.arimo(
                                          fontSize: 11 * scale,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (imageUrls.length > 1) ...[
                      SizedBox(height: 8 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imageUrls.length,
                          (i) => Container(
                            width: 6 * scale,
                            height: 6 * scale,
                            margin: EdgeInsets.symmetric(horizontal: 2 * scale),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == currentIndex
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 16 * scale),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          'Đóng',
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          },
        );
      },
    );
  }

  Future<void> _openSignedContractLink(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.inAppWebView);
    if (!opened && mounted) {
      AppToast.showError(
        context,
        message: 'Không thể mở liên kết hợp đồng đã ký',
      );
    }
  }

  void _handleUploadSignedPressed() {
    _showUploadSignedSheet();
  }


  bool _isPdf(ContractModel contract) {
    final url = contract.fileUrl;
    if (url == null || url.trim().isEmpty) {
      if (contract.images != null && contract.images!.isNotEmpty) return false;
      return false;
    }
    // If it's a list string, check if the first one is PDF
    final firstUrl = url.contains(',') ? url.split(',').first : url;
    return RegExp(r'\.pdf(\?|$)', caseSensitive: false).hasMatch(firstUrl);
  }

  bool _isImage(ContractModel contract) {
    if (contract.images != null && contract.images!.isNotEmpty) return true;
    
    final url = contract.fileUrl;
    if (url == null || url.trim().isEmpty) {
      return false;
    }
    if (url.contains(',')) return true;
    return RegExp(
      r'\.(png|jpe?g|gif|webp|bmp)(\?|$)',
      caseSensitive: false,
    ).hasMatch(url) || url.contains('image/upload');
  }

  String _fileTypeLabelText(ContractModel contract) {
    if (_isPdf(contract)) {
      return 'PDF';
    }
    if (_isImage(contract)) {
      final count = contract.images?.length ?? 
                    (contract.fileUrl?.contains(',') == true ? contract.fileUrl!.split(',').length : 1);
      return count > 1 ? 'Ảnh • $count' : 'Ảnh';
    }
    return 'Khác';
  }

  Future<void> _showUploadSignedSheet() async {
    final contract = _contract;
    if (contract == null) return;

    DateTime signedDate = contract.signedDate ?? DateTime.now();
    final picker = ImagePicker();
    List<String> pickedImagePaths = [];
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
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
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
                  return SingleChildScrollView(
                    child: Column(
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
                                'Chọn nhiều ảnh hợp đồng đã ký từ camera hoặc thư viện',
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
                                      pickedImagePaths.add(image.path);
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
                                  final images = await picker.pickMultiImage(
                                    imageQuality: 85,
                                    maxWidth: 1600,
                                  );
                                  if (images.isNotEmpty) {
                                    setModalState(() {
                                      pickedImagePaths.addAll(
                                        images.map((img) => img.path),
                                      );
                                    });
                                  }
                                },
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  // ── Khu vực hiển thị ảnh đã chọn ──
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                        color: pickedImagePaths.isNotEmpty
                            ? const Color(0xFF0EA5E9).withValues(alpha: 0.3)
                            : AppColors.borderLight,
                        width: pickedImagePaths.isNotEmpty ? 2 : 1,
                      ),
                      color: pickedImagePaths.isNotEmpty
                          ? const Color(0xFF0EA5E9).withValues(alpha: 0.05)
                          : AppColors.background,
                    ),
                    child: pickedImagePaths.isEmpty
                        ? Row(
                            children: [
                              const Icon(Icons.image_outlined),
                              SizedBox(width: 10 * scale),
                              Expanded(
                                child: Text(
                                  'Chưa chọn ảnh nào',
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
                                      'Đã chọn ${pickedImagePaths.length} ảnh',
                                      style: AppTextStyles.arimo(
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (!isUploading)
                                    TextButton.icon(
                                      onPressed: () {
                                        setModalState(() {
                                          pickedImagePaths.clear();
                                        });
                                      },
                                      icon: Icon(Icons.delete_outline,
                                          size: 16 * scale,
                                          color: Colors.red),
                                      label: Text(
                                        'Xoá hết',
                                        style: AppTextStyles.arimo(
                                          fontSize: 12 * scale,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8 * scale),
                              // Grid hiển thị ảnh
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8 * scale,
                                  crossAxisSpacing: 8 * scale,
                                  childAspectRatio: 1,
                                ),
                                itemCount: pickedImagePaths.length,
                                itemBuilder: (_, index) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8 * scale),
                                        child: Image.file(
                                          File(pickedImagePaths[index]),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: AppColors.background,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              size: 24 * scale,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Nút xoá từng ảnh
                                      if (!isUploading)
                                        Positioned(
                                          top: 2 * scale,
                                          right: 2 * scale,
                                          child: GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                pickedImagePaths.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(3 * scale),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.55),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 14 * scale,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Số thứ tự
                                      Positioned(
                                        bottom: 2 * scale,
                                        left: 2 * scale,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6 * scale,
                                            vertical: 2 * scale,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.55),
                                            borderRadius: BorderRadius.circular(4 * scale),
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: AppTextStyles.arimo(
                                              fontSize: 10 * scale,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
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
                              if (pickedImagePaths.isEmpty) {
                                AppToast.showError(
                                  context,
                                  message: 'Vui lòng chọn/chụp ít nhất 1 ảnh hợp đồng đã ký',
                                );
                                return;
                              }

                              setModalState(() => isUploading = true);
                              try {
                                final navigator = Navigator.of(ctx);
                                final message = await _remote.uploadSignedFile(
                                  id: contract.id,
                                  filePaths: pickedImagePaths,
                                  signedDate: signedDate,
                                );
                                if (!mounted) return;
                                navigator.pop();
                                AppToast.showSuccess(this.context, message: message);
                                final updated =
                                    await _remote.getContractById(contract.id);
                                if (!mounted) return;
                                setState(() {
                                  _contract = updated;
                                });
                              } catch (e) {
                                if (mounted) {
                                  AppToast.showError(
                                    this.context,
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
                        isUploading
                            ? 'Đang upload ${pickedImagePaths.length} ảnh...'
                            : 'Upload ${pickedImagePaths.length} ảnh',
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditContentSheet() async {
    final contract = _contract;
    if (contract == null) return;

    final currentCustomerName =
        (contract.customer?.username ?? _bookingCustomer?.username ?? '').trim();
    final currentCustomerPhone =
        (contract.customer?.phone ?? _bookingCustomer?.phone ?? '').trim();

    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final customerAddressController = TextEditingController();
    final totalController = TextEditingController();
    final discountController = TextEditingController();
    final finalController = TextEditingController();

    DateTime? effectiveFrom = contract.effectiveFrom;
    DateTime? effectiveTo = contract.effectiveTo;
    DateTime? checkinDate = contract.checkinDate;
    DateTime? checkoutDate = contract.checkoutDate;

    final originalEffectiveFrom = contract.effectiveFrom;
    final originalEffectiveTo = contract.effectiveTo;
    final originalCheckinDate = contract.checkinDate;
    final originalCheckoutDate = contract.checkoutDate;

    bool finalAmountManualOverride = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final scale = AppResponsive.scaleFactor(ctx);

        InputDecoration buildFieldDecoration({
          required String label,
          required String hint,
          String? helper,
          Widget? suffix,
        }) {
          return InputDecoration(
            labelText: label,
            hintText: hint,
            helperText: helper,
            suffixIcon: suffix,
            alignLabelWithHint: true,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 14 * scale,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(
                color: AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(
                color: AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16 * scale,
            right: 16 * scale,
            top: 12 * scale,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16 * scale,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              double? parseMoney(String text) {
                if (text.trim().isEmpty) return null;
                final raw = text.replaceAll('.', '').replaceAll(',', '').trim();
                return double.tryParse(raw);
              }

              String formatMoney(double value) {
                final rounded = value.round();
                final text = rounded.toString();
                final buffer = StringBuffer();
                for (int i = 0; i < text.length; i++) {
                  final reverseIndex = text.length - i;
                  buffer.write(text[i]);
                  if (reverseIndex > 1 && reverseIndex % 3 == 1) {
                    buffer.write('.');
                  }
                }
                return buffer.toString();
              }

              void recomputeFinalAmount() {
                if (finalAmountManualOverride) return;
                final total = parseMoney(totalController.text);
                final discount = parseMoney(discountController.text) ?? 0;
                if (total == null) {
                  finalController.clear();
                  return;
                }
                final amount =
                    (total - discount).clamp(0, double.infinity).toDouble();
                finalController.text = formatMoney(amount);
              }

              Widget sectionTitle(String text, IconData icon) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10 * scale, top: 2 * scale),
                  child: Row(
                    children: [
                      Icon(icon, size: 17 * scale, color: AppColors.primary),
                      SizedBox(width: 6 * scale),
                      Text(
                        text,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              Widget datePickerTile({
                required String label,
                required DateTime? value,
                required ValueChanged<DateTime> onChanged,
              }) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12 * scale),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setModalState(() => onChanged(picked));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * scale,
                      vertical: 12 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: AppTextStyles.arimo(
                                  fontSize: 11 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 3 * scale),
                              Text(
                                value != null ? _formatDate(value) : 'Chọn ngày',
                                style: AppTextStyles.arimo(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 18 * scale,
                        ),
                      ],
                    ),
                  ),
                );
              }

              Future<void> handleSubmit() async {
                final changedItems = <String>[];

                final customerName = customerNameController.text.trim();
                final customerPhone = customerPhoneController.text.trim();
                final customerAddress = customerAddressController.text.trim();
                final totalPrice = parseMoney(totalController.text);
                final discountAmount = parseMoney(discountController.text);
                final finalAmount = parseMoney(finalController.text);

                if (customerName.isNotEmpty) changedItems.add('Tên khách hàng');
                if (customerPhone.isNotEmpty) changedItems.add('Số điện thoại');
                if (customerAddress.isNotEmpty) changedItems.add('Địa chỉ');
                if (effectiveFrom != originalEffectiveFrom) {
                  changedItems.add('Hiệu lực từ');
                }
                if (effectiveTo != originalEffectiveTo) {
                  changedItems.add('Hiệu lực đến');
                }
                if (checkinDate != originalCheckinDate) changedItems.add('Check-in');
                if (checkoutDate != originalCheckoutDate) {
                  changedItems.add('Check-out');
                }
                if (totalPrice != null) changedItems.add('Tổng tiền');
                if (discountAmount != null) changedItems.add('Giảm giá');
                if (finalAmount != null) changedItems.add('Thành tiền');

                if (changedItems.isEmpty) {
                  AppToast.showError(
                    this.context,
                    message: 'Bạn chưa nhập thay đổi nào để lưu',
                  );
                  return;
                }

                if (!mounted) return;
                final confirmed = await showDialog<bool>(
                  context: this.context,
                  builder: (dialogCtx) {
                    return AlertDialog(
                      title: const Text('Xác nhận cập nhật'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bạn sắp ghi đè các thông tin:'),
                          const SizedBox(height: 8),
                          ...changedItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $item'),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(true),
                          child: const Text('Xác nhận lưu'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed != true) return;

                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                try {
                  final updated = await _remote.updateContent(
                    contract.id,
                    customerName: customerName.isEmpty ? null : customerName,
                    customerPhone: customerPhone.isEmpty ? null : customerPhone,
                    customerAddress:
                        customerAddress.isEmpty ? null : customerAddress,
                    effectiveFrom: effectiveFrom != originalEffectiveFrom
                        ? effectiveFrom
                        : null,
                    effectiveTo:
                        effectiveTo != originalEffectiveTo ? effectiveTo : null,
                    checkinDate: checkinDate != originalCheckinDate
                        ? checkinDate
                        : null,
                    checkoutDate: checkoutDate != originalCheckoutDate
                        ? checkoutDate
                        : null,
                    totalPrice: totalPrice,
                    discountAmount: discountAmount,
                    finalAmount: finalAmount,
                  );

                  if (!mounted) return;
                  AppToast.showSuccess(
                    this.context,
                    message: 'Cập nhật hợp đồng thành công',
                  );
                  setState(() {
                    _contract = updated;
                  });
                } catch (e) {
                  if (!mounted) return;
                  AppToast.showError(
                    this.context,
                    message: 'Không thể cập nhật hợp đồng: $e',
                  );
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40 * scale,
                        height: 4 * scale,
                        margin: EdgeInsets.only(bottom: 12 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2 * scale),
                        ),
                      ),
                    ),
                    Text(
                      'Chỉnh sửa nội dung hợp đồng',
                      style: AppTextStyles.arimo(
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      'Lưu ý: Chỉ điền các thông tin cần thay đổi, các ô để trống sẽ giữ nguyên nội dung cũ.',
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16 * scale),

                    sectionTitle('Thông tin khách hàng', Icons.person_outline_rounded),
                    TextField(
                      controller: customerNameController,
                      decoration: buildFieldDecoration(
                        label: 'Tên khách hàng',
                        hint: 'Để trống nếu giữ nguyên',
                        helper: currentCustomerName.isNotEmpty
                            ? 'Hiện tại: $currentCustomerName'
                            : null,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: customerPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: buildFieldDecoration(
                        label: 'Số điện thoại',
                        hint: 'Để trống nếu giữ nguyên',
                        helper: currentCustomerPhone.isNotEmpty
                            ? 'Hiện tại: $currentCustomerPhone'
                            : null,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: customerAddressController,
                      decoration: buildFieldDecoration(
                        label: 'Địa chỉ',
                        hint: 'Để trống nếu giữ nguyên',
                      ),
                    ),

                    SizedBox(height: 14 * scale),
                    sectionTitle('Thời gian', Icons.schedule_rounded),
                    datePickerTile(
                      label: 'Hiệu lực từ',
                      value: effectiveFrom,
                      onChanged: (v) => effectiveFrom = v,
                    ),
                    SizedBox(height: 8 * scale),
                    datePickerTile(
                      label: 'Hiệu lực đến',
                      value: effectiveTo,
                      onChanged: (v) => effectiveTo = v,
                    ),
                    SizedBox(height: 8 * scale),
                    datePickerTile(
                      label: 'Check-in',
                      value: checkinDate,
                      onChanged: (v) => checkinDate = v,
                    ),
                    SizedBox(height: 8 * scale),
                    datePickerTile(
                      label: 'Check-out',
                      value: checkoutDate,
                      onChanged: (v) => checkoutDate = v,
                    ),

                    SizedBox(height: 14 * scale),
                    sectionTitle('Chi phí', Icons.payments_outlined),
                    TextField(
                      controller: totalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        recomputeFinalAmount();
                        setModalState(() {});
                      },
                      decoration: buildFieldDecoration(
                        label: 'Tổng tiền',
                        hint: 'Nhập số tiền (để trống nếu giữ nguyên)',
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 10 * scale),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              'VNĐ',
                              style: AppTextStyles.arimo(
                                fontSize: 11 * scale,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: discountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        recomputeFinalAmount();
                        setModalState(() {});
                      },
                      decoration: buildFieldDecoration(
                        label: 'Giảm giá',
                        hint: 'Nhập số tiền giảm (để trống nếu giữ nguyên)',
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 10 * scale),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              'VNĐ',
                              style: AppTextStyles.arimo(
                                fontSize: 11 * scale,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    TextField(
                      controller: finalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        finalAmountManualOverride =
                            finalController.text.trim().isNotEmpty;
                        setModalState(() {});
                      },
                      decoration: buildFieldDecoration(
                        label: 'Thành tiền',
                        hint:
                            'Tự động tính từ Tổng tiền - Giảm giá (có thể sửa tay)',
                        helper: finalAmountManualOverride
                            ? 'Đang dùng giá trị nhập tay'
                            : 'Đang tự động tính',
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 10 * scale),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              'VNĐ',
                              style: AppTextStyles.arimo(
                                fontSize: 11 * scale,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 18 * scale),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 14 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                        ),
                        icon: Icon(Icons.save_rounded, size: 18 * scale),
                        label: Text(
                          'Lưu thay đổi',
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
    final hasSignedFile = contract?.fileUrl?.trim().isNotEmpty == true || contract?.images?.isNotEmpty == true;
    final isSigned = contract?.status.toLowerCase() == 'signed';
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
                              color: const Color(0xFF1D4ED8),
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
                // Customer row with clear null fallback
                _buildCustomerRow(contract, scale),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 360;
                    final spacing = 12 * scale;
                    final itemWidth = isNarrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _ActionButton(
                            icon: Icons.edit_note_rounded,
                            label: 'Chỉnh sửa',
                            color: const Color(0xFF7C3AED),
                            onPressed: _showEditContentSheet,
                            scale: scale,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _ActionButton(
                            icon: Icons.visibility_rounded,
                            label: 'Xem trước hợp đồng',
                            color: const Color(0xFF0284C7),
                            onPressed: _openPreview,
                            scale: scale,
                            isOutlined: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _ActionButton(
                            icon: Icons.picture_as_pdf_rounded,
                            label: _isLoading ? 'Đang tải...' : 'Xuất PDF',
                            color: AppColors.primary,
                            onPressed: _isLoading ? null : _downloadPdf,
                            scale: scale,
                            isOutlined: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _ActionButton(
                            icon: Icons.cloud_upload_rounded,
                            label: 'Upload file đã ký',
                            color: const Color(0xFF0EA5E9),
                            onPressed: contract.status.toLowerCase() == 'draft'
                                ? null
                                : _handleUploadSignedPressed,
                            scale: scale,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (contract.status.toLowerCase() == 'draft') ...[
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
                          'Vui lòng bấm "Gửi khách" trước khi tính năng Upload được mở',
                          style: AppTextStyles.arimo(
                            fontSize: 11 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 12 * scale),
                // Gửi khách — cho phép gửi ngay cả khi chưa upload file đã ký (để khách xem bản draft)
                // Khoá gửi nếu đã có file upload hoàn tất hoặc hợp đồng đã ký
                _ActionButton(
                  icon: Icons.send_rounded,
                  label: _isSending
                      ? 'Đang gửi...'
                      : isSigned
                          ? 'Đã ký - Không thể gửi'
                          : 'Gửi khách',
                  color: const Color(0xFF2563EB),
                  onPressed: (_isSending || hasSignedFile || isSigned) ? null : _sendContract,
                  scale: scale,
                  isOutlined: true,
                  isFullWidth: true,
                ),
                if (hasSignedFile || isSigned) ...[
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 13 * scale,
                        color: const Color(0xFF16A34A),
                      ),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
                          isSigned
                              ? 'Hợp đồng đã được ký, không thể gửi lại'
                              : 'Hợp đồng đã hoàn tất upload file chữ ký, không cần gửi thêm',
                          style: AppTextStyles.arimo(
                            fontSize: 11 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  _ActionButton(
                    icon: _isPdf(contract)
                        ? Icons.picture_as_pdf_rounded
                        : Icons.image_rounded,
                    label:
                        'Xem file đã ký (${_fileTypeLabelText(contract)})',
                    color: const Color(0xFF059669),
                    onPressed: _openSignedContractImage,
                    scale: scale,
                    isOutlined: true,
                    isFullWidth: true,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 32 * scale),
        ],
      ),
    );
  }

  /// Customer row with clear null fallback + booking-level customer lookup
  Widget _buildCustomerRow(ContractModel contract, double scale) {
    // Ưu tiên customer từ contract, fallback sang customer được fetch từ booking
    final customerName = contract.customer?.username ?? _bookingCustomer?.username;
    final customerEmail = contract.customer?.email ?? _bookingCustomer?.email;
    final customerPhone = contract.customer?.phone ?? _bookingCustomer?.phone;
    final hasCustomer =
        (customerName?.trim().isNotEmpty == true) ||
        (customerEmail?.trim().isNotEmpty == true);
    final displayName = customerName?.trim().isNotEmpty == true
        ? customerName!
        : (customerEmail?.trim().isNotEmpty == true
            ? customerEmail!
            : null);

    return Container(
      padding: EdgeInsets.all(12 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: hasCustomer
                ? Icon(
                    Icons.person_outline_rounded,
                    size: 18 * scale,
                    color: AppColors.textSecondary,
                  )
                : Icon(
                    Icons.person_off_outlined,
                    size: 18 * scale,
                    color: AppColors.textSecondary,
                  ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khách hàng',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4 * scale),
                if (hasCustomer) ...[
                  Text(
                    displayName!,
                    style: AppTextStyles.arimo(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (customerEmail != null &&
                      customerEmail.trim().isNotEmpty &&
                      customerName?.trim().isNotEmpty == true) ...[
                    SizedBox(height: 2 * scale),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 12 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4 * scale),
                        Expanded(
                          child: Text(
                            customerEmail,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (customerPhone != null &&
                      customerPhone.trim().isNotEmpty) ...[
                    SizedBox(height: 2 * scale),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 12 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          customerPhone,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  Row(
                    children: [
                      Text(
                        'Chưa có khách hàng',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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
