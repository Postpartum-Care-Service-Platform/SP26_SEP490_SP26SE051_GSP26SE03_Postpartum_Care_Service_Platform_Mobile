import 'package:equatable/equatable.dart';

/// Structured data returned together with an AI message
/// to render rich UI (tables, cards, etc.).
class AiStructuredData extends Equatable {
  final String type;
  final String text;
  final List<Map<String, dynamic>> data;

  const AiStructuredData({
    required this.type,
    required this.text,
    required this.data,
  });

  @override
  List<Object?> get props => [type, text, data];
}

