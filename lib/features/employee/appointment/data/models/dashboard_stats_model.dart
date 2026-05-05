class DashboardStatsModel {
  final int pendingBookingsCount;
  final int pendingAppointmentsCount;
  final int draftContractsCount;
  final int pendingSupportRequestsCount;

  DashboardStatsModel({
    required this.pendingBookingsCount,
    required this.pendingAppointmentsCount,
    required this.draftContractsCount,
    required this.pendingSupportRequestsCount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      pendingBookingsCount: json['pendingBookingsCount'] ?? 0,
      pendingAppointmentsCount: json['pendingAppointmentsCount'] ?? 0,
      draftContractsCount: json['draftContractsCount'] ?? 0,
      pendingSupportRequestsCount: json['pendingSupportRequestsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendingBookingsCount': pendingBookingsCount,
      'pendingAppointmentsCount': pendingAppointmentsCount,
      'draftContractsCount': draftContractsCount,
      'pendingSupportRequestsCount': pendingSupportRequestsCount,
    };
  }
}
