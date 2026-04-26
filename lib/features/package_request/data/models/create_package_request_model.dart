class CreatePackageRequestModel {
  final int basePackageId;
  final String title;
  final String description;
  final String requestedStartDate;
  final int totalDays;
  final List<int> familyProfileIds;

  CreatePackageRequestModel({
    required this.basePackageId,
    required this.title,
    required this.description,
    required this.requestedStartDate,
    required this.totalDays,
    required this.familyProfileIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'basePackageId': basePackageId,
      'title': title,
      'description': description,
      'requestedStartDate': requestedStartDate,
      'totalDays': totalDays,
      'familyProfileIds': familyProfileIds,
    };
  }
}
