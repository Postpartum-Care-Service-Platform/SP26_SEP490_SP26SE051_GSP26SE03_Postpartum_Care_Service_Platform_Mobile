import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../contract/data/datasources/contract_remote_datasource.dart';
import '../../../contract/data/models/contract_preview_model.dart';

/// Staff xem preview hợp đồng (draft) theo booking (GET /Contract/preview/{bookingId})
class StaffContractPreviewScreen extends StatefulWidget {
  final int bookingId;

  const StaffContractPreviewScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<StaffContractPreviewScreen> createState() =>
      _StaffContractPreviewScreenState();
}

class _StaffContractPreviewScreenState
    extends State<StaffContractPreviewScreen> {
  final _remote = ContractRemoteDataSourceImpl(dio: ApiClient.dio);

  late Future<ContractPreviewModel> _future =
      _remote.previewContractByBooking(widget.bookingId);

  Future<void> _refresh() async {
    setState(() {
      _future = _remote.previewContractByBooking(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Preview hợp đồng',
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<ContractPreviewModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text(
                  'Lỗi tải preview hợp đồng: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final preview = snapshot.data;
          if (preview == null) {
            return Center(
              child: Text(
                'Không có nội dung preview.',
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: AppColors.primary,
                        size: 24 * scale,
                      ),
                      SizedBox(width: 12 * scale),
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
                              preview.contractCode,
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
                  ),
                ),
                SizedBox(height: 16 * scale),
                Container(
                  padding: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.preview,
                            size: 18 * scale,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            'Nội dung hợp đồng (Preview)',
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * scale),
                      Divider(height: 1, color: AppColors.borderLight),
                      SizedBox(height: 12 * scale),
                      // Hiển thị HTML content (có thể dùng html package nếu cần render HTML)
                      // Hiện tại hiển thị dạng text, có thể cải thiện sau bằng html widget
                      SelectableText(
                        preview.htmlContent,
                        style: AppTextStyles.arimo(fontSize: 13 * scale),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

