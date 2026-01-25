import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
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
    // Chuẩn hoá xuống dòng: bỏ bớt các dòng trống liên tiếp và loại bỏ dòng markdown ---
    final lines = raw.split('\n');
    final buffer = <String>[];
    var lastBlank = false;
    for (final line in lines) {
      final trimmed = line.trim();
      final isBlank = trimmed.isEmpty;
      // Bỏ các dòng chỉ chứa --- (horizontal rule markdown)
      final isHorizontalRule = RegExp(r'^-{3,}$').hasMatch(trimmed);
      if (isHorizontalRule) continue;
      
      if (isBlank) {
        if (!lastBlank) buffer.add('');
      } else {
        buffer.add(line.trimRight());
      }
      lastBlank = isBlank;
    }
    return buffer.join('\n');
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

    List<String> parseRow(String line) {
      final trimmed = line.trim();
      final withoutPipes =
          trimmed.substring(1, trimmed.length - 1); // remove leading/trailing |
      return withoutPipes.split('|').map((c) => c.trim()).toList();
    }

    final headers = parseRow(lines.first);
    final rows = <List<String>>[];
    for (var i = 2; i < lines.length; i++) {
      rows.add(parseRow(lines[i]));
    }

    // Xác định index cột Giá (dựa trên header chứa từ 'giá' không phân biệt hoa thường)
    int? priceColumnIndex;
    // Xác định index cột Thời gian (header chứa 'thời gian' hoặc 'ngày')
    int? durationColumnIndex;
    for (var i = 0; i < headers.length; i++) {
      final headerLower = headers[i].toLowerCase();
      if (headerLower.contains('giá') || headerLower.contains('gia')) {
        priceColumnIndex = i;
      }
      if (headerLower.contains('thời gian') ||
          headerLower.contains('thoi gian') ||
          headerLower.contains('ngày') ||
          headerLower.contains('ngay')) {
        durationColumnIndex = i;
      }
    }

    TableColumnWidth columnWidthForIndex(int index) {
      // Tối ưu cho bảng 5 cột: STT | Tên Gói | Thời Gian | Giá | Mô Tả
      if (headers.length == 5) {
        switch (index) {
          case 0: // STT
            return const FlexColumnWidth(0.6);
          case 1: // Tên gói
            return const FlexColumnWidth(1.1);
          case 2: // Thời gian
            // tăng nhẹ để \"14 ngày\" hiển thị trên một dòng
            return const FlexColumnWidth(1.2);
          case 3: // Giá
            return const FlexColumnWidth(1.1);
          case 4: // Mô tả
            return const FlexColumnWidth(1.6);
        }
      }
      // Mặc định: chia đều
      return const FlexColumnWidth();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Table(
          columnWidths: {
            for (int i = 0; i < headers.length; i++) i: columnWidthForIndex(i),
          },
          border: TableBorder(
            horizontalInside: BorderSide(
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
                      vertical: 6 * scale,
                    ),
                    child: _buildInlineMarkdownText(
                      h,
                      scale,
                      AppColors.textPrimary,
                      isBaseBold: true,
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
                        vertical: 6 * scale,
                      ),
                      child: _buildInlineMarkdownText(
                        i < row.length
                            ? (priceColumnIndex != null &&
                                    i == priceColumnIndex
                                ? _formatPriceFromString(row[i])
                                : (durationColumnIndex != null &&
                                        i == durationColumnIndex
                                    ? _formatDurationFromString(row[i])
                                    : row[i]))
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
    );
  }

  Widget _buildMarkdownWithTables(
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
      return line.startsWith('|') &&
          line.endsWith('|') &&
          RegExp(r'^\|(?:\s*:?-+:?\s*\|)+\s*$').hasMatch(next);
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

  String _formatPriceFromString(String raw) {
    final matches = RegExp(r'\d+').allMatches(raw);
    final digits = matches.map((m) => m.group(0)!).join();
    if (digits.isEmpty) return raw;

    final value = int.tryParse(digits);
    if (value == null) return raw;

    final v = value;
    if (v <= 0) return '$v đ';

    if (v >= 1000000000) {
      final billions = v ~/ 1000000000;
      final rem = v % 1000000000;
      if (rem == 0) return '$billions tỉ';
      final millions = rem ~/ 1000000;
      if (rem % 1000000 == 0 && millions > 0) {
        return '$billions tỉ $millions triệu';
      }
      return '$billions tỉ';
    }

    if (v >= 1000000) {
      final millions = v ~/ 1000000;
      final rem = v % 1000000;
      if (rem == 0) return '$millions triệu';

      if (rem % 100000 == 0) {
        final tenth = rem ~/ 100000;
        return '$millions triệu $tenth';
      }
      return '$millions triệu';
    }

    if (v >= 1000 && v % 1000 == 0) {
      final unit = v ~/ 1000;
      return '$unit ngàn';
    }

    if (v >= 100 && v % 100 == 0) {
      final unit = v ~/ 100;
      return '$unit trăm';
    }

    return '$v đ';
  }

  String _formatDurationFromString(String raw) {
    // Lấy phần số ngày trong chuỗi, ví dụ: "30 d", "14d", "14 ngày" -> 30, 14...
    final match = RegExp(r'\d+').firstMatch(raw);
    if (match == null) return raw;
    final digits = match.group(0);
    if (digits == null) return raw;
    final v = int.tryParse(digits);
    if (v == null) return raw;
    return '$v ngày';
  }

  List<TextSpan> _buildMarkdownSpans({
    required String text,
    required double scale,
    required Color color,
    required bool isBaseBold,
    double baseFontSize = 14,
  }) {
    final baseStyle = AppTextStyles.arimo(
      fontSize: baseFontSize * scale,
      color: color,
      fontWeight: isBaseBold ? FontWeight.w700 : FontWeight.w500,
    ).copyWith(height: 1.4);

    final pattern = RegExp(
      r'(\*\*.+?\*\*|__.+?__|\*.+?\*|_.+?_+|~~.+?~~)',
      dotAll: true,
    );

    final spans = <TextSpan>[];
    var currentIndex = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;
      TextStyle style = baseStyle;
      String content = matchText;

      if ((matchText.startsWith('**') && matchText.endsWith('**')) ||
          (matchText.startsWith('__') && matchText.endsWith('__'))) {
        content = matchText.substring(2, matchText.length - 2);
        style = baseStyle.copyWith(fontWeight: FontWeight.w800);
      } else if ((matchText.startsWith('*') && matchText.endsWith('*')) ||
          (matchText.startsWith('_') && matchText.endsWith('_'))) {
        content = matchText.substring(1, matchText.length - 1);
        style = baseStyle.copyWith(fontStyle: FontStyle.italic);
      } else if (matchText.startsWith('~~') && matchText.endsWith('~~')) {
        content = matchText.substring(2, matchText.length - 2);
        style = baseStyle.copyWith(decoration: TextDecoration.lineThrough);
      }

      spans.add(TextSpan(text: content, style: style));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }

  Widget _buildInlineMarkdownText(
    String text,
    double scale,
    Color color, {
    bool isBaseBold = false,
    double baseFontSize = 14,
  }) {
    final spans = _buildMarkdownSpans(
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

