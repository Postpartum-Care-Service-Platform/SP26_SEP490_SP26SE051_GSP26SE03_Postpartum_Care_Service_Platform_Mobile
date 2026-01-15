import '../../domain/entities/ai_structured_data.dart';

class AiStructuredDataModel extends AiStructuredData {
  const AiStructuredDataModel({
    required super.type,
    required super.text,
    required super.data,
  });

  factory AiStructuredDataModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<Map<String, dynamic>> parsedData = [];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          parsedData.add(item);
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData.add(rawData);
    }

    return AiStructuredDataModel(
      type: (json['type'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      data: parsedData,
    );
  }
}

