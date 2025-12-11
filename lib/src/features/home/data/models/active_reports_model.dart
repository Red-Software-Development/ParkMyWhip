class ActiveReportModel {
  final String id;
  final String adminRole;
  final String plateNumber;
  final String reportedBy;
  final String additionalNotes;
  final String attachedImage;
  final DateTime submitTime;
  final String carDetails;

  ActiveReportModel({
    required this.id,
    required this.adminRole,
    required this.plateNumber,
    required this.reportedBy,
    required this.additionalNotes,
    required this.attachedImage,
    required this.submitTime,
    required this.carDetails,
  });

  factory ActiveReportModel.fromJson(Map<String, dynamic> json) {
    return ActiveReportModel(
      id: json['id'],
      adminRole: json['adminRole'],
      plateNumber: json['plateNumber'],
      reportedBy: json['reportedBy'],
      additionalNotes: json['additionalNotes'],
      attachedImage: json['attachedImage'],
      carDetails: json['carDetails'],
      submitTime: DateTime.parse(json['submitTime']),
    );
  }
}
