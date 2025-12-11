class HistoryReportModel {
  final String id;
  final String adminRole;
  final String plateNumber;
  final String reportedBy;
  final String expiredReason;
  final DateTime submitTime;
  final String carDetails;

  HistoryReportModel({
    required this.id,
    required this.adminRole,
    required this.plateNumber,
    required this.reportedBy,
    required this.expiredReason,
    required this.submitTime,
    required this.carDetails,
  });

  factory HistoryReportModel.fromJson(Map<String, dynamic> json) {
    return HistoryReportModel(
      id: json['id'],
      adminRole: json['adminRole'],
      plateNumber: json['plateNumber'],
      reportedBy: json['reportedBy'],
      carDetails: json['carDetails'],
      expiredReason: json['expiredReason'],
      submitTime: DateTime.parse(json['submitTime']),
    );
  }
}
