import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import 'app_text_styles.dart';

/// Markdown utilities for parsing and formatting markdown text
class AppMarkdownUtils {
  AppMarkdownUtils._();

  /// Normalize markdown content: remove excessive blank lines and horizontal rules
  static String normalizeContent(String raw) {
    final lines = raw.split('\n');
    final buffer = <String>[];
    var lastBlank = false;
    for (final line in lines) {
      final trimmed = line.trim();
      final isBlank = trimmed.isEmpty;
      // Remove horizontal rule markdown (---)
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

  /// Build preview text from markdown: remove tables, separators, and markdown syntax
  static String buildPreviewText(String text) {
    if (text.isEmpty) return AppStrings.chatTypingHint;

    // Remove markdown table lines and separator '---'
    final lines = text.split('\n');
    final buffer = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('|')) continue;
      if (trimmed.startsWith('---')) continue;
      buffer.add(trimmed);
    }
    text = buffer.join(' ');

    // Remove simple markdown symbols: **bold**, _italic_, __bold__, ~~del~~
    text = text
        .replaceAllMapped(
            RegExp(r'(\*\*|__)(.+?)(\*\*|__)'), (m) => m[2] ?? '')
        .replaceAllMapped(RegExp(r'(\*|_)(.+?)(\*|_)'), (m) => m[2] ?? '')
        .replaceAllMapped(RegExp(r'(~~)(.+?)(~~)'), (m) => m[2] ?? '');

    // Normalize whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (text.isEmpty) return AppStrings.chatTypingHint;
    return text;
  }

  /// Parse markdown text into TextSpans for RichText
  static List<TextSpan> buildMarkdownSpans({
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

  /// Check if a line is a markdown table header line
  static bool isTableHeaderLine(String line, String? nextLine) {
    if (nextLine == null) return false;
    final trimmed = line.trim();
    final nextTrimmed = nextLine.trim();
    return trimmed.startsWith('|') &&
        trimmed.endsWith('|') &&
        RegExp(r'^\|(?:\s*:?-+:?\s*\|)+\s*$').hasMatch(nextTrimmed);
  }

  /// Parse markdown table row into list of cells
  static List<String> parseTableRow(String line) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('|') || !trimmed.endsWith('|')) {
      return [];
    }
    final withoutPipes =
        trimmed.substring(1, trimmed.length - 1); // remove leading/trailing |
    return withoutPipes.split('|').map((c) => c.trim()).toList();
  }

  /// Find column index by header keyword (case-insensitive)
  static int? findColumnIndexByKeyword(
    List<String> headers,
    List<String> keywords,
  ) {
    for (var i = 0; i < headers.length; i++) {
      final headerLower = headers[i].toLowerCase();
      for (final keyword in keywords) {
        if (headerLower.contains(keyword.toLowerCase())) {
          return i;
        }
      }
    }
    return null;
  }
}
