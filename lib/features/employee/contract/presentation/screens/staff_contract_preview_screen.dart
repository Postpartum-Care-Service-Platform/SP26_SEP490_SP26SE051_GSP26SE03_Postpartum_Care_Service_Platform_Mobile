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
    'margin-top': '4px',
    'margin-bottom': '4px',
    'line-height': '1.5',
  },
  'table': {
    'width': '100%',
    'min-width': '100%',
    'border-collapse': 'collapse',
    'margin-top': '12px',
    'margin-bottom': '12px',
    'background-color': '#ffffff',
    'table-layout': 'fixed',
  },
  'th': {
    'padding': '8px 6px',
    'border': '1px solid #d1d5db',
    'background-color': '#f3f4f6',
    'font-weight': '600',
    'text-align': 'left',
  },
  'td': {
    'padding': '8px 6px',
    'border': '1px solid #e5e7eb',
    'vertical-align': 'top',
  },
};

class StaffContractPreviewScreen extends StatefulWidget {
  final int bookingId;
  /// Pre-fetched preview data — nếu có sẵn sẽ hiển thị ngay, không cần gọi API.
  final ContractPreviewModel? initialPreview;

  const StaffContractPreviewScreen({super.key, required this.bookingId, this.initialPreview});

  @override
  State<StaffContractPreviewScreen> createState() => _StaffContractPreviewScreenState();
}

class _StaffContractPreviewScreenState extends State<StaffContractPreviewScreen> {
  final _remote = ContractRemoteDataSourceImpl(dio: ApiClient.dio);
  late Future<ContractPreviewModel> _future;

  @override
  void initState() {
    super.initState();
    // Nếu đã có data sẵn → dùng ngay, không gọi API
    _future = widget.initialPreview != null
        ? Future.value(widget.initialPreview!)
        : _remote.previewContractByBooking(widget.bookingId);
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
        title: 'Hợp đồng',
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

          // Signature table: no borders, respect left/right alignment
          if (tag == 'table' && element.className.contains('sig-table')) {
            return {
              'width': '100%',
              'table-layout': 'fixed',
              'border': 'none',
              'margin-top': '32px',
              'margin-bottom': '60px',
            };
          }
          if (tag == 'td' && element.className.contains('sig-left')) {
            return {
              'width': '50%',
              'border': 'none',
              'text-align': 'left',
              'vertical-align': 'top',
              'padding': '0',
            };
          }
          if (tag == 'td' && element.className.contains('sig-right')) {
            return {
              'width': '50%',
              'border': 'none',
              'text-align': 'right',
              'vertical-align': 'top',
              'padding': '0',
            };
          }

          // Force signature cells in legacy no-border tables
          if (tag == 'td' && element.parent?.localName == 'tr') {
            final table = element.parent?.parent?.parent;
            if (table?.localName == 'table' && table?.className.contains('no-border') == true) {
              return {'text-align': 'center', 'border': 'none', 'padding': '0'};
            }
          }

          final styles = _htmlStyleMap[tag];
          Map<String, String> mergedStyles = styles != null ? Map.from(styles) : {};
          
          if (tag == 'p' || tag == 'div') {
            // Apply justification to normal paragraphs only
            // Skip if inside signature section
            final parentClass = element.parent?.className ?? '';
            if (!parentClass.contains('sig-')) {
              mergedStyles['text-align'] = 'justify';
            }
          }

          if (tag == 'table' && !element.className.contains('sig-table')) {
            return {
              'width': '100%',
              'min-width': '100%',
              'table-layout': 'fixed',
              'border-collapse': 'collapse',
              'margin-bottom': '16px',
            };
          }

          // Label columns in data tables
          if (tag == 'td' && element.parent?.localName == 'tr' && element == element.parent?.children.first) {
             if (!element.className.contains('no-border') && !element.className.contains('sig-')) {
               return {'width': '35%', 'font-weight': '600', 'background-color': '#f9fafb', 'border': '1px solid #e5e7eb'};
             }
          }
          
          return mergedStyles.isEmpty ? null : mergedStyles;
        },
      ),
    );
  }

  String _processHtml(String html) {
    String processed = html;

    // 1. Clean up potential extra whitespace or invisible characters
    processed = processed.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

    // 2. Force all tables to be 100% width and standardized
    processed = processed.replaceAll(
      '<table',
      '<table style="width: 100% !important; border-collapse: collapse; margin-bottom: 16px;" width="100%"',
    );

    // 3. Process data table rows for consistent label/value look
    processed = processed.replaceAllMapped(
      RegExp(r'<tr[^>]*>\s*<td([^>]*)>(.*?)</td>', dotAll: true),
      (match) {
        final attrs = match.group(1) ?? '';
        final content = match.group(2) ?? '';
        
        if (!attrs.contains('no-border') && 
            !content.contains('ĐẠI DIỆN') && 
            !content.contains('Ký, ghi rõ họ tên')) {
          return '<tr style="width: 100%;"><td style="width: 35%; font-weight: 600; background-color: #f9fafb; border: 1px solid #e5e7eb; padding: 8px 6px;" $attrs>$content</td>';
        }
        return match.group(0)!;
      },
    );

    // 4. Replace the entire signature section with a proper 2-column table
    // Strategy: find <div class="signature"> and replace everything until its closing </div>
    const signatureTable = '''
<table class="sig-table">
  <tr>
    <td class="sig-left">
      <p style="font-weight:bold; margin-bottom:4px;">ĐẠI DIỆN BÊN A</p>
      <p style="font-style:italic; font-size:12px; color:#666;">(Ký, ghi rõ họ tên)</p>
    </td>
    <td class="sig-right">
      <p style="font-weight:bold; margin-bottom:4px;">ĐẠI DIỆN BÊN B</p>
      <p style="font-style:italic; font-size:12px; color:#666;">(Ký, ghi rõ họ tên)</p>
    </td>
  </tr>
</table>
''';

    // Try class="signature" anchor first (most reliable)
    final sigDivIdx = processed.indexOf('class="signature"');
    if (sigDivIdx != -1) {
      // Find the opening <div that contains this class
      final divOpenIdx = processed.lastIndexOf('<div', sigDivIdx);
      if (divOpenIdx != -1) {
        // Find the matching closing tag — count nested divs
        int depth = 0;
        int searchIdx = divOpenIdx;
        int closeIdx = -1;
        while (searchIdx < processed.length) {
          final nextOpen = processed.indexOf('<div', searchIdx + 1);
          final nextClose = processed.indexOf('</div>', searchIdx + 1);
          
          if (nextClose == -1) break;
          
          if (nextOpen != -1 && nextOpen < nextClose) {
            depth++;
            searchIdx = nextOpen;
          } else {
            if (depth == 0) {
              closeIdx = nextClose + 6; // length of '</div>'
              break;
            }
            depth--;
            searchIdx = nextClose;
          }
        }
        
        if (closeIdx != -1) {
          processed = processed.substring(0, divOpenIdx) + signatureTable + processed.substring(closeIdx);
        }
      }
    } else if (processed.contains('ĐẠI DIỆN BÊN')) {
      // Fallback: text-based replacement
      try {
        final startMatch = RegExp(r'ĐẠI\s*DIỆN\s*BÊN\s*A', caseSensitive: false).firstMatch(processed);
        final endMatches = RegExp(r'\(Ký,\s*ghi\s*rõ\s*họ\s*tên\)', caseSensitive: false).allMatches(processed);
        
        if (startMatch != null && endMatches.length >= 2) {
          // Find the outermost enclosing div
          int startIdx = startMatch.start;
          int endIdx = endMatches.last.end;
          
          // Expand to enclosing div
          int divStart = processed.lastIndexOf('<div', startIdx);
          if (divStart == -1 || (startIdx - divStart) > 200) divStart = startIdx;
          
          int divEnd = processed.indexOf('</div>', endIdx);
          if (divEnd != -1 && (divEnd - endIdx) < 200) {
            divEnd += 6;
          } else {
            divEnd = endIdx;
          }
          
          processed = processed.substring(0, divStart) + signatureTable + processed.substring(divEnd);
        }
      } catch (e) {
        debugPrint('Error processing signature HTML: $e');
      }
    }

    // Clean up any trailing empty <p></p> after signature
    processed = processed.replaceAll(RegExp(r'</table>\s*<p>\s*</p>'), '</table>');

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
