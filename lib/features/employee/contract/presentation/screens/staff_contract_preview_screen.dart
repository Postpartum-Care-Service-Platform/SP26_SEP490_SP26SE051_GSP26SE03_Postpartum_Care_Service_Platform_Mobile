import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../../features/contract/data/datasources/contract_remote_datasource.dart';
import '../../../../../features/contract/data/models/contract_preview_model.dart';

/// Optimized Style Map for HTML Rendering
/// O(1) access instead of switch-case logic
final Map<String, Map<String, String>> _htmlStyleMap = {
  'h1': {
    'font-weight': 'bold',
    'font-size': '18px',
    'margin-top': '16px',
    'margin-bottom': '12px',
    'color': '#1a1a1a',
    'text-align': 'center',
  },
  'h2': {
    'font-weight': 'bold',
    'font-size': '16px',
    'margin-top': '12px',
    'margin-bottom': '8px',
    'color': '#1a1a1a',
  },
  'p': {
    'margin-top': '8px',
    'margin-bottom': '8px',
    'line-height': '1.6',
    'text-align': 'justify',
  },
  'table': {
    'width': '100%',
    'min-width': '100%',
    'border-collapse': 'collapse',
    'margin-top': '16px',
    'margin-bottom': '16px',
    'background-color': '#ffffff',
    'table-layout': 'fixed',
    'display': 'table',
  },
  'th': {
    'padding': '10px 8px',
    'border': '1px solid #d1d5db',
    'background-color': '#f3f4f6',
    'font-weight': '600',
    'text-align': 'left',
  },
  'td': {
    'padding': '10px 8px',
    'border': '1px solid #e5e7eb',
    'vertical-align': 'top',
  },
};

class StaffContractPreviewScreen extends StatefulWidget {
  final int bookingId;

  const StaffContractPreviewScreen({super.key, required this.bookingId});

  @override
  State<StaffContractPreviewScreen> createState() => _StaffContractPreviewScreenState();
}

class _StaffContractPreviewScreenState extends State<StaffContractPreviewScreen> {
  final _remote = ContractRemoteDataSourceImpl(dio: ApiClient.dio);
  late Future<ContractPreviewModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _remote.previewContractByBooking(widget.bookingId);
  }

  void _refresh() {
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
        title: 'Xem trước hợp đồng',
        centerTitle: true,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: FutureBuilder<ContractPreviewModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SmartLoadingOverlay();
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString(), scale);
          }
          if (snapshot.hasData) {
            return _ContractContentView(preview: snapshot.data!, scale: scale);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error, double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48 * scale, color: AppColors.red),
            const SizedBox(height: 16),
            Text('Lỗi tải dữ liệu: $error', textAlign: TextAlign.center, style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary)),
            TextButton(onPressed: _refresh, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _ContractContentView extends StatelessWidget {
  final ContractPreviewModel preview;
  final double scale;

  const _ContractContentView({required this.preview, required this.scale});

  @override
  Widget build(BuildContext context) {
    final processedHtml = _processHtml(preview.htmlContent);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildHtmlContainer(processedHtml),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 28 * scale),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MÃ HỢP ĐỒNG DỰ KIẾN', style: AppTextStyles.arimo(fontSize: 11 * scale, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                Text(preview.contractCode, style: AppTextStyles.tinos(fontSize: 18 * scale, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlContainer(String html) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: HtmlWidget(
        html,
        textStyle: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textPrimary, height: 1.5),
        customStylesBuilder: (element) {
          final tag = element.localName?.toLowerCase();
          final styles = _htmlStyleMap[tag];
          if (styles != null) return styles;
          
          if (tag == 'table') {
            return {
              'width': '100%',
              'min-width': '100%',
              'table-layout': 'fixed',
              'display': 'table',
              'margin-left': '0',
              'margin-right': '0',
            };
          }
          // Force labels to have consistent width across all tables (approx 35%)
          if (tag == 'td' && element.parent?.localName == 'tr' && element == element.parent?.children.first) {
             if (!element.className.contains('no-border')) {
               return {'width': '35%', 'font-weight': '600', 'background-color': '#f9fafb'};
             }
          }
          return null;
        },
      ),
    );
  }

  String _processHtml(String html) {
    String processed = html;

    // 1. Force all tables to be 100% width by injecting style directly into the tag
    // This overrides any backend-defined width attributes
    processed = processed.replaceAll(
      '<table',
      '<table style="width: 100% !important; min-width: 100% !important; table-layout: fixed; border-collapse: collapse; margin-bottom: 16px;" width="100%"',
    );

    // 2. Standardize column widths for all data tables (35% for labels, 65% for values)
    // We target the first <td> in each <tr> that doesn't belong to a 'no-border' table
    processed = processed.replaceAllMapped(
      RegExp(r'<tr[^>]*>\s*<td([^>]*)>(.*?)</td>', dotAll: true),
      (match) {
        final attrs = match.group(1) ?? '';
        final content = match.group(2) ?? '';
        // If it's the first column of a standard table, force its width
        if (!attrs.contains('no-border') && !content.contains('ĐẠI DIỆN')) {
          return '<tr style="width: 100%;"><td style="width: 35%; font-weight: 600; background-color: #f9fafb; border: 1px solid #e5e7eb; padding: 10px 8px;" $attrs>$content</td>';
        }
        return match.group(0)!;
      },
    );

    // 3. Process the signature section for perfect balance
    if (processed.contains('ĐẠI DIỆN BÊN A') || processed.contains('ĐẠI DIỆN BÊN B')) {
      try {
        int startIdx = processed.indexOf('ĐẠI DIỆN BÊN A');
        int lastSignIdx = processed.lastIndexOf('(Ký, ghi rõ họ tên)');
        
        if (startIdx != -1 && lastSignIdx != -1 && lastSignIdx > startIdx) {
          int endIdx = processed.indexOf('</', lastSignIdx);
          if (endIdx != -1) {
            endIdx = processed.indexOf('>', endIdx) + 1;
          } else {
            endIdx = lastSignIdx + '(Ký, ghi rõ họ tên)'.length;
          }

          final originalBlock = processed.substring(startIdx, endIdx);
          const signInstruction = '(Ký, ghi rõ họ tên)';
          const tableHtml = '''
          <table class="no-border" style="width:100% !important; margin-top:40px; margin-bottom:40px; table-layout: fixed; border: none !important;">
            <tr style="border: none !important;">
              <td style="width:50%; border:none !important; text-align:center; vertical-align:top; padding: 0;">
                <p style="font-weight:bold; margin-bottom:4px;">ĐẠI DIỆN BÊN A</p>
                <p style="font-style:italic; font-size:12px; color:#666;">$signInstruction</p>
              </td>
              <td style="width:50%; border:none !important; text-align:center; vertical-align:top; padding: 0;">
                <p style="font-weight:bold; margin-bottom:4px;">ĐẠI DIỆN BÊN B</p>
                <p style="font-style:italic; font-size:12px; color:#666;">$signInstruction</p>
              </td>
            </tr>
          </table>
          ''';
          processed = processed.replaceFirst(originalBlock, tableHtml);
        }
      } catch (e) {
        debugPrint('Error processing signature HTML: $e');
      }
    }

    return processed;
  }
}

class _SmartLoadingOverlay extends StatelessWidget {
  const _SmartLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLoadingIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Đang chuẩn bị bản thảo...',
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
