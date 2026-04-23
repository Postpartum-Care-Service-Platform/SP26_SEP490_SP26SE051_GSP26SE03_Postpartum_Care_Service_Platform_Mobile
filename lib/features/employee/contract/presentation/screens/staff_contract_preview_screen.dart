import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../features/contract/data/datasources/contract_remote_datasource.dart';
import '../../../../../features/contract/data/models/contract_preview_model.dart';

/// Staff xem preview hợp đồng (draft) theo booking (GET /Contract/preview/{bookingId})
class StaffContractPreviewScreen extends StatefulWidget {
  final int bookingId;

  const StaffContractPreviewScreen({super.key, required this.bookingId});

  @override
  State<StaffContractPreviewScreen> createState() =>
      _StaffContractPreviewScreenState();
}

class _StaffContractPreviewScreenState
    extends State<StaffContractPreviewScreen> {
  final _remote = ContractRemoteDataSourceImpl(dio: ApiClient.dio);

  late Future<ContractPreviewModel> _future = _remote.previewContractByBooking(
    widget.bookingId,
  );

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
            return const _ContractLoadingWidget();
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
          if (preview == null || preview.htmlContent.isEmpty) {
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

          String contentHtml = preview.htmlContent;

          // Tự động phân tích và đưa phần chữ ký 2 bên ngang hàng
          if (contentHtml.contains('ĐẠI DIỆN BÊN A') && contentHtml.contains('ĐẠI DIỆN BÊN B')) {
            int indexA = contentHtml.indexOf('ĐẠI DIỆN BÊN A');
            int indexB = contentHtml.indexOf('ĐẠI DIỆN BÊN B');
            
            if (indexA != -1 && indexB != -1 && indexA < indexB) {
              int startIndex = contentHtml.lastIndexOf('<p', indexA);
              if (startIndex == -1) startIndex = contentHtml.lastIndexOf('<div', indexA);
              if (startIndex == -1) startIndex = indexA;
              
              int signatureTextB = contentHtml.indexOf('(Ký, ghi rõ họ tên)', indexB);
              if (signatureTextB != -1) {
                int endIndex = contentHtml.indexOf('</p>', signatureTextB);
                if (endIndex == -1) endIndex = contentHtml.indexOf('</div>', signatureTextB);
                if (endIndex != -1) endIndex += 4;
                else endIndex = signatureTextB + '(Ký, ghi rõ họ tên)'.length;
                
                String originalSignaturesBlock = contentHtml.substring(startIndex, endIndex);
                int startBInBlock = originalSignaturesBlock.indexOf('ĐẠI DIỆN BÊN B');
                
                if (startBInBlock > 0) {
                  int splitIndex = originalSignaturesBlock.lastIndexOf('<p', startBInBlock);
                  if (splitIndex == -1) splitIndex = originalSignaturesBlock.lastIndexOf('<div', startBInBlock);
                  if (splitIndex <= 0) splitIndex = startBInBlock;
                  
                  String blockA = originalSignaturesBlock.substring(0, splitIndex).trim();
                  String blockB = originalSignaturesBlock.substring(splitIndex).trim();
                  
                  String tableHtml = '''
                  <table class="signature-table no-border" style="width:100%; margin-top:32px;">
                    <tr class="no-border">
                      <td class="no-border" style="width:50%;">
                        $blockA
                      </td>
                      <td class="no-border" style="width:50%;">
                        $blockB
                      </td>
                    </tr>
                  </table>
                  ''';
                  
                  contentHtml = contentHtml.replaceFirst(originalSignaturesBlock, tableHtml);
                }
              }
            }
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
                      SizedBox(height: 16 * scale),
                      // Container cho HTML content với background nhẹ
                      Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8 * scale),
                          border: Border.all(
                            color: AppColors.borderLight.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: HtmlWidget(
                          contentHtml,
                          textStyle: AppTextStyles.arimo(
                            fontSize: 15 * scale,
                            color: AppColors.textPrimary,
                          ),
                          customStylesBuilder: (element) {
                            final tag = element.localName?.toLowerCase();
                            final className = element.className;
                            
                            switch (tag) {
                              case 'h1':
                                return {
                                  'font-weight': 'bold',
                                  'font-size': '18px',
                                  'margin-top': '16px',
                                  'margin-bottom': '12px',
                                  'color': '#1a1a1a',
                                  'text-align': 'center',
                                };
                              case 'h2':
                              case 'h3':
                                return {
                                  'font-weight': 'bold',
                                  'font-size': '16px',
                                  'margin-top': '12px',
                                  'margin-bottom': '8px',
                                  'color': '#1a1a1a',
                                };
                              case 'p':
                                return {
                                  'margin-top': '8px',
                                  'margin-bottom': '8px',
                                  'line-height': '1.6',
                                  'text-align': 'justify',
                                };
                              case 'table':
                                if (className.contains('no-border')) {
                                  return {
                                    'width': '100%',
                                    'margin-top': '24px',
                                  };
                                }
                                return {
                                  'width': '100%',
                                  'border-collapse': 'collapse',
                                  'margin-top': '16px',
                                  'margin-bottom': '16px',
                                  'background-color': '#ffffff',
                                };
                              case 'th':
                                return {
                                  'padding': '10px 8px',
                                  'border': '1px solid #d1d5db',
                                  'background-color': '#f3f4f6',
                                  'font-weight': '600',
                                  'text-align': 'left',
                                };
                              case 'td':
                                if (className.contains('no-border')) {
                                  return {
                                    'padding': '0',
                                    'border': 'none',
                                    'text-align': 'center',
                                    'vertical-align': 'top',
                                  };
                                }
                                return {
                                  'padding': '10px 8px',
                                  'border': '1px solid #e5e7eb',
                                  'vertical-align': 'top',
                                };
                              default:
                                if (className.contains('title')) {
                                  return {
                                    'font-weight': 'bold',
                                    'font-size': '16px',
                                    'margin-bottom': '8px',
                                  };
                                }
                                return null;
                            }
                          },
                        ),
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

class _ContractLoadingWidget extends StatefulWidget {
  const _ContractLoadingWidget();

  @override
  State<_ContractLoadingWidget> createState() => _ContractLoadingWidgetState();
}

class _ContractLoadingWidgetState extends State<_ContractLoadingWidget> with SingleTickerProviderStateMixin {
  int _messageIndex = 0;
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  final List<String> _messages = [
    'Đang khởi tạo bản thảo hợp đồng...',
    'Đang kiểm tra thông tin đối tác...',
    'Đang biên soạn các điều khoản dịch vụ...',
    'Đang định dạng văn bản pháp lý...',
    'Đang chuẩn bị bản xem trước...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 100 * scale,
              height: 100 * scale,
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 3 * scale,
                  ),
                  Icon(
                    Icons.history_edu,
                    size: 40 * scale,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32 * scale),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _messages[_messageIndex],
              key: ValueKey<int>(_messageIndex),
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            'Vui lòng đợi trong giây lát',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
