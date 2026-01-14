import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../domain/entities/chat_message.dart';
import 'chat_time_utils.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isAI;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final String displayName;
  final String? avatarUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isAI,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    required this.displayName,
    this.avatarUrl,
  });

  String _formatContent() {
    final raw = message.content.trimRight();
    if (!isAI) return raw;
    // Chuẩn hoá xuống dòng: bỏ bớt các dòng trống liên tiếp
    final lines = raw.split('\n');
    final buffer = <String>[];
    var lastBlank = false;
    for (final line in lines) {
      final isBlank = line.trim().isEmpty;
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
    final formatted = _formatContent();
    final maxWidth =
        MediaQuery.of(context).size.width * (isAI ? 0.9 : 0.8);

    if (!isAI) {
      return _buildPlainText(formatted, maxWidth, scale, textColor);
    }

    if (_looksLikeMarkdownTable(formatted)) {
      return _buildMarkdownTable(formatted, maxWidth, scale);
    }

    return _buildMarkdownText(formatted, maxWidth, scale, textColor);
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

  bool _looksLikeMarkdownTable(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) return false;
    final first = lines.first;
    final second = lines[1];
    final isRow = first.startsWith('|') && first.endsWith('|');
    final isSeparator = RegExp(r'^\|(?:\s*-+\s*\|)+\s*$').hasMatch(second);
    return isRow && isSeparator;
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

    List<String> _parseRow(String line) {
      final trimmed = line.trim();
      final withoutPipes =
          trimmed.substring(1, trimmed.length - 1); // remove leading/trailing |
      return withoutPipes.split('|').map((c) => c.trim()).toList();
    }

    final headers = _parseRow(lines.first);
    final rows = <List<String>>[];
    for (var i = 2; i < lines.length; i++) {
      rows.add(_parseRow(lines[i]));
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
            for (int i = 0; i < headers.length; i++)
              i: const FlexColumnWidth(),
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
                    child: Text(
                      h,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
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
                      child: Text(
                        i < row.length ? row[i] : '',
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownText(
    String text,
    double maxWidth,
    double scale,
    Color textColor,
  ) {
    final baseStyle = AppTextStyles.arimo(
      fontSize: 14 * scale,
      color: textColor,
      fontWeight: FontWeight.w500,
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
        style = baseStyle.copyWith(fontWeight: FontWeight.w700);
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

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: RichText(
        text: TextSpan(children: spans),
        textAlign: TextAlign.left,
        softWrap: true,
      ),
    );
  }
}

