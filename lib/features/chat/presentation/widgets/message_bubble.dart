import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_markdown_utils.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ai_structured_data.dart';
import 'chat_time_utils.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isAI;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final String displayName;
  final String? avatarUrl;
  final AiStructuredData? structuredData;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isAI,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    required this.displayName,
    this.avatarUrl,
    this.structuredData,
  });

  String _formatContent() {
    final raw = message.content.trimRight();
    if (!isAI) return raw;
    return AppMarkdownUtils.normalizeContent(raw);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final bubbleColor = isMine
        ? AppColors.primary
        : Colors.black.withValues(alpha: 0.06);
    final textColor = isMine ? AppColors.white : AppColors.textPrimary;
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final radius = 18 * scale;
    final small = 4 * scale;
    final borderRadius = BorderRadius.circular(radius).copyWith(
      topLeft: Radius.circular(
        isMine ? radius : (isFirstInGroup ? radius : small),
      ),
      bottomLeft: Radius.circular(
        isMine ? radius : (isLastInGroup ? radius : small),
      ),
      topRight: Radius.circular(
        isMine ? (isFirstInGroup ? radius : small) : radius,
      ),
      bottomRight: Radius.circular(
        isMine ? (isLastInGroup ? radius : small) : radius,
      ),
    );

    final showAvatar = isLastInGroup;
    final avatarSize = 28 * scale;
    final senderType = message.senderType.toLowerCase();
    final isStaff = senderType == 'staff' ||
        senderType == 'employee' ||
        senderType == 'nurse' ||
        senderType == 'consultant';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine)
            SizedBox(
              width: avatarSize + 8 * scale,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: showAvatar
                    ? (isAI || isStaff
                        ? SvgPicture.asset(
                            AppAssets.appIconThird,
                            width: avatarSize,
                            height: avatarSize,
                          )
                        : AvatarWidget(
                            size: 28,
                            imageUrl: avatarUrl,
                            displayName: displayName,
                            borderWidth: 0,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                          ))
                    : SizedBox(height: avatarSize),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContent(context, scale, textColor),
                      SizedBox(height: 6 * scale),
                      Text(
                        formatChatTime(message.createdAt),
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMine)
            SizedBox(
              width: avatarSize + 8 * scale,
              child: Align(
                alignment: Alignment.bottomRight,
                child: showAvatar
                    ? AvatarWidget(
                        size: 28,
                        imageUrl: avatarUrl,
                        displayName: displayName,
                        borderWidth: 0,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                      )
                    : SizedBox(height: avatarSize),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, double scale, Color textColor) {
    final maxWidth =
        MediaQuery.of(context).size.width * (isAI ? 0.9 : 0.8);

    if (!isAI) {
      final formatted = _formatContent();
      return _buildPlainText(formatted, maxWidth, scale, textColor);
    }

    // Nếu message AI có JSON đã format, hiển thị dưới dạng code block (giống <pre><code>)
    if (message.hasJson && (message.formattedJson ?? '').isNotEmpty) {
      return _buildCodeBlock(
        message.formattedJson!,
        maxWidth,
        scale,
        textColor,
      );
    }

    final formatted = _formatContent();

    // Với AI: luôn render dựa trên markdown (text + nhiều bảng), không dùng aiStructuredData nữa
    return _buildMarkdownWithTables(
      context,
      formatted,
      maxWidth,
      scale,
      textColor,
    );
  }

  Widget _buildCodeBlock(
    String text,
    double maxWidth,
    double scale,
    Color textColor,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.all(10 * scale),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10 * scale),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: textColor,
              fontWeight: FontWeight.w400,
            ).copyWith(
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlainText(
    String text,
    double maxWidth,
    double scale,
    Color textColor,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        textAlign: TextAlign.left,
        softWrap: true,
        style: AppTextStyles.arimo(
          fontSize: 14 * scale,
          color: textColor,
          fontWeight: FontWeight.w500,
        ).copyWith(height: 1.4),
      ),
    );
  }

  Widget _buildMarkdownTable(
    BuildContext context,
    String text,
    double maxWidth,
    double scale,
  ) {
    final lines = text
        .split('\n')
        .map((l) => l.trimRight())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) {
      return _buildPlainText(text, maxWidth, scale, AppColors.textPrimary);
    }

    final headers = AppMarkdownUtils.parseTableRow(lines.first);
    final rows = <List<String>>[];
    for (var i = 2; i < lines.length; i++) {
      final row = AppMarkdownUtils.parseTableRow(lines[i]);
      if (row.isNotEmpty) {
        rows.add(row);
      }
    }

    // Xác định index cột Giá, Thời gian (giờ), và Duration (ngày)
    final priceColumnIndex = AppMarkdownUtils.findColumnIndexByKeyword(
      headers,
      ['giá', 'gia', 'price'],
    );
    // Thời gian = giờ (07:00, 09:00-10:30)
    final timeColumnIndex = AppMarkdownUtils.findColumnIndexByKeyword(
      headers,
      ['thời gian', 'thoi gian', 'time', 'giờ', 'gio'],
    );
    // Duration = ngày (14 ngày, 30 ngày)
    final durationColumnIndex = AppMarkdownUtils.findColumnIndexByKeyword(
      headers,
      ['duration', 'ngày', 'ngay', 'số ngày', 'so ngay'],
    );

    // Tính toán width tối thiểu cho mỗi cột dựa trên nội dung
    double calculateMinColumnWidth(int index) {
      double maxWidth = 0;
      // Kiểm tra header
      final headerText = headers[index];
      final headerWidth = headerText.length * 8.0 * scale;
      maxWidth = headerWidth > maxWidth ? headerWidth : maxWidth;
      
      // Kiểm tra các cell trong cột
      for (final row in rows) {
        if (index < row.length) {
          final cellText = row[index];
          final cellWidth = cellText.length * 8.0 * scale;
          maxWidth = cellWidth > maxWidth ? cellWidth : maxWidth;
        }
      }
      
      // Đảm bảo width tối thiểu
      return (maxWidth + 32 * scale).clamp(80 * scale, double.infinity);
    }

    final columnWidths = <int, TableColumnWidth>{};
    double totalMinWidth = 0;
    for (int i = 0; i < headers.length; i++) {
      final minWidth = calculateMinColumnWidth(i);
      columnWidths[i] = FixedColumnWidth(minWidth);
      totalMinWidth += minWidth;
    }

    // Tạo bảng với scroll ngang
    final tableWidget = Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Table(
        columnWidths: columnWidths,
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 0.5,
          ),
          verticalInside: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
            ),
            children: [
              for (final h in headers)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 8 * scale,
                  ),
                  child: _buildInlineMarkdownText(
                    h,
                    scale,
                    AppColors.textPrimary,
                    isBaseBold: true,
                    baseFontSize: 13,
                  ),
                ),
            ],
          ),
          for (final row in rows)
            TableRow(
              children: [
                for (var i = 0; i < headers.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 8 * scale,
                    ),
                    child: _buildTableCellText(
                      i < row.length
                          ? (timeColumnIndex != null && i == timeColumnIndex
                              ? AppFormatters.formatTimeFromString(row[i])
                              : (durationColumnIndex != null &&
                                      i == durationColumnIndex
                                  ? AppFormatters.formatDurationFromString(row[i])
                                  : (priceColumnIndex != null &&
                                          i == priceColumnIndex
                                      ? AppFormatters.formatPriceFromString(row[i])
                                      : row[i])))
                          : '',
                      scale,
                      AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );

    // Wrap trong SingleChildScrollView để cho phép scroll ngang
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: totalMinWidth.clamp(0, maxWidth),
              ),
              child: tableWidget,
            ),
          ),
          // Nút expand ở góc trên bên phải
          Positioned(
            top: 4 * scale,
            right: 4 * scale,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showExpandedTable(
                  context,
                  text,
                  scale,
                  headers,
                  rows,
                  priceColumnIndex,
                  timeColumnIndex,
                  durationColumnIndex,
                ),
                borderRadius: BorderRadius.circular(20 * scale),
                child: Container(
                  padding: EdgeInsets.all(6 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.open_in_full,
                    size: 16 * scale,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpandedTable(
    BuildContext context,
    String text,
    double scale,
    List<String> headers,
    List<List<String>> rows,
    int? priceColumnIndex,
    int? timeColumnIndex,
    int? durationColumnIndex,
  ) {
    showDialog(
      context: context,
      builder: (context) => _TableExpandDialog(
        text: text,
        scale: scale,
        headers: headers,
        rows: rows,
        priceColumnIndex: priceColumnIndex,
        timeColumnIndex: timeColumnIndex,
        durationColumnIndex: durationColumnIndex,
      ),
    );
  }

  Widget _buildTableCellText(
    String text,
    double scale,
    Color color,
  ) {
    // Text trong cell không wrap, cho phép scroll ngang ở cấp bảng
    final spans = AppMarkdownUtils.buildMarkdownSpans(
      text: text,
      scale: scale,
      color: color,
      isBaseBold: false,
      baseFontSize: 13,
    );
    
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
      softWrap: false, // Không wrap text
      overflow: TextOverflow.clip, // Clip text thay vì ellipsis để có thể scroll
    );
  }

  Widget _buildMarkdownWithTables(
    BuildContext context,
    String text,
    double maxWidth,
    double scale,
    Color textColor,
  ) {
    final lines = text.split('\n');
    final blocks = <Widget>[];
    final buffer = <String>[];

    bool isHeaderLine(int index) {
      if (index < 0 || index >= lines.length - 1) return false;
      final line = lines[index].trim();
      final next = lines[index + 1].trim();
      return AppMarkdownUtils.isTableHeaderLine(line, next);
    }

    int i = 0;
    while (i < lines.length) {
      if (isHeaderLine(i)) {
        // Đổ buffer hiện tại thành 1 block markdown text
        if (buffer.isNotEmpty) {
          final beforeText = buffer.join('\n').trim();
          if (beforeText.isNotEmpty) {
            blocks.add(
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: _buildMarkdownText(
                  beforeText,
                  maxWidth,
                  scale,
                  textColor,
                ),
              ),
            );
          }
          buffer.clear();
        }

        // Gom block bảng
        final tableLines = <String>[];
        var j = i;
        for (; j < lines.length; j++) {
          final trimmed = lines[j].trimRight();
          if (trimmed.isEmpty) break;
          if (!trimmed.startsWith('|')) break;
          tableLines.add(trimmed);
        }

        if (tableLines.length >= 2) {
          blocks.add(
            _buildMarkdownTable(
              context,
              tableLines.join('\n'),
              maxWidth,
              scale,
            ),
          );
        }

        i = j;
        continue;
      } else {
        buffer.add(lines[i]);
        i++;
      }
    }

    // Phần text còn lại sau bảng cuối
    if (buffer.isNotEmpty) {
      final afterText = buffer.join('\n').trim();
      if (afterText.isNotEmpty) {
        blocks.add(
          Padding(
            padding: EdgeInsets.only(top: 8 * scale),
            child: _buildMarkdownText(
              afterText,
              maxWidth,
              scale,
              textColor,
            ),
          ),
        );
      }
    }

    if (blocks.isEmpty) {
      return _buildMarkdownText(text, maxWidth, scale, textColor);
    }
    if (blocks.length == 1) return blocks.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }

  Widget _buildMarkdownText(
    String text,
    double maxWidth,
    double scale,
    Color textColor,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final line in text.split('\n'))
            _buildMarkdownLine(line, scale, textColor),
        ],
      ),
    );
  }



  Widget _buildInlineMarkdownText(
    String text,
    double scale,
    Color color, {
    bool isBaseBold = false,
    double baseFontSize = 14,
  }) {
    final spans = AppMarkdownUtils.buildMarkdownSpans(
      text: text,
      scale: scale,
      color: color,
      isBaseBold: isBaseBold,
      baseFontSize: baseFontSize,
    );

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
      softWrap: true,
    );
  }

  Widget _buildMarkdownLine(
    String line,
    double scale,
    Color textColor,
  ) {
    final trimmed = line.trimRight();
    if (trimmed.isEmpty) {
      return SizedBox(height: 4 * scale);
    }

    int level = 0;
    String body = trimmed;
    if (trimmed.startsWith('### ')) {
      level = 3;
      body = trimmed.substring(4);
    } else if (trimmed.startsWith('## ')) {
      level = 2;
      body = trimmed.substring(3);
    } else if (trimmed.startsWith('# ')) {
      level = 1;
      body = trimmed.substring(2);
    }

    double baseFontSize;
    bool baseBold;
    EdgeInsets padding;

    if (level == 0) {
      baseFontSize = 14;
      baseBold = false;
      padding = EdgeInsets.zero;
    } else if (level == 1) {
      baseFontSize = 18;
      baseBold = true;
      padding = EdgeInsets.only(bottom: 6 * scale);
    } else if (level == 2) {
      baseFontSize = 16;
      baseBold = true;
      padding = EdgeInsets.only(bottom: 4 * scale, top: 2 * scale);
    } else {
      // level 3+
      baseFontSize = 15;
      baseBold = true;
      padding = EdgeInsets.only(bottom: 2 * scale, left: 2 * scale);
    }

    return Padding(
      padding: padding,
      child: _buildInlineMarkdownText(
        body,
        scale,
        textColor,
        isBaseBold: baseBold,
        baseFontSize: baseFontSize,
      ),
    );
  }
}

class _TableExpandDialog extends StatelessWidget {
  final String text;
  final double scale;
  final List<String> headers;
  final List<List<String>> rows;
  final int? priceColumnIndex;
  final int? timeColumnIndex;
  final int? durationColumnIndex;

  const _TableExpandDialog({
    required this.text,
    required this.scale,
    required this.headers,
    required this.rows,
    this.priceColumnIndex,
    this.timeColumnIndex,
    this.durationColumnIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Tính toán width tối thiểu cho mỗi cột
    double calculateMinColumnWidth(int index) {
      double maxWidth = 0;
      final headerText = headers[index];
      final headerWidth = headerText.length * 10.0 * scale;
      maxWidth = headerWidth > maxWidth ? headerWidth : maxWidth;
      
      for (final row in rows) {
        if (index < row.length) {
          final cellText = row[index];
          final cellWidth = cellText.length * 10.0 * scale;
          maxWidth = cellWidth > maxWidth ? cellWidth : maxWidth;
        }
      }
      
      return (maxWidth + 40 * scale).clamp(100 * scale, double.infinity);
    }

    final columnWidths = <int, TableColumnWidth>{};
    double totalMinWidth = 0;
    for (int i = 0; i < headers.length; i++) {
      final minWidth = calculateMinColumnWidth(i);
      columnWidths[i] = FixedColumnWidth(minWidth);
      totalMinWidth += minWidth;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16 * scale),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth - 32 * scale,
          maxHeight: screenHeight * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với nút đóng
            Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.chatTableDetailTitle,
                    style: AppTextStyles.arimo(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24 * scale),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
            // Bảng với scroll cả ngang và dọc
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: totalMinWidth,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    margin: EdgeInsets.all(16 * scale),
                    child: Table(
                      columnWidths: columnWidths,
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                        verticalInside: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                          ),
                          children: [
                            for (final h in headers)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * scale,
                                  vertical: 12 * scale,
                                ),
                                child: _buildInlineMarkdownText(
                                  h,
                                  scale,
                                  AppColors.textPrimary,
                                  isBaseBold: true,
                                  baseFontSize: 14,
                                ),
                              ),
                          ],
                        ),
                        for (final row in rows)
                          TableRow(
                            children: [
                              for (var i = 0; i < headers.length; i++)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12 * scale,
                                    vertical: 12 * scale,
                                  ),
                                  child: _buildTableCellText(
                                    i < row.length
                                        ? (timeColumnIndex != null && i == timeColumnIndex
                                            ? AppFormatters.formatTimeFromString(row[i])
                                            : (durationColumnIndex != null &&
                                                    i == durationColumnIndex
                                                ? AppFormatters.formatDurationFromString(row[i])
                                                : (priceColumnIndex != null &&
                                                        i == priceColumnIndex
                                                    ? AppFormatters.formatPriceFromString(row[i])
                                                    : row[i])))
                                        : '',
                                    scale,
                                    AppColors.textPrimary,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineMarkdownText(
    String text,
    double scale,
    Color color, {
    bool isBaseBold = false,
    double baseFontSize = 14,
  }) {
    final spans = AppMarkdownUtils.buildMarkdownSpans(
      text: text,
      scale: scale,
      color: color,
      isBaseBold: isBaseBold,
      baseFontSize: baseFontSize,
    );

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
      softWrap: true,
    );
  }

  Widget _buildTableCellText(
    String text,
    double scale,
    Color color,
  ) {
    final spans = AppMarkdownUtils.buildMarkdownSpans(
      text: text,
      scale: scale,
      color: color,
      isBaseBold: false,
      baseFontSize: 13,
    );

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
  }
}
