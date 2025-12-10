class PermitModel {
  final String id;
  final String permitType; // e.g. 'Yearly'
  final DateTime expiryDate;
  final VehicleInfo vehicleInfo;
  final PlateSpotInfo plateSpotInfo;

  PermitModel({
    required this.id,
    required this.permitType,
    required this.expiryDate,
    required this.vehicleInfo,
    required this.plateSpotInfo,
  });

  factory PermitModel.fromJson(Map<String, dynamic> json) {
    return PermitModel(
      id: json['id'],
      permitType: json['permitType'],
      expiryDate: DateTime.parse(json['expiryDate']),
      vehicleInfo: VehicleInfo(
        model: json['vehicleInfo']['model'],
        year: json['vehicleInfo']['year'],
        color: json['vehicleInfo']['color'],
      ),
      plateSpotInfo: PlateSpotInfo(
        plateNumber: json['plateSpotInfo']['plateNumber'],
        spotNumber: json['plateSpotInfo']['spotNumber'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permitType': permitType,
      'expiryDate': expiryDate.toIso8601String(),
      'vehicleInfo': vehicleInfo.toJson(),
      'plateSpotInfo': plateSpotInfo.toJson(),
    };
  }
}

class VehicleInfo {
  final String model; // Chevrolet-Silverado
  final String year; // 2024
  final String color; // Black

  VehicleInfo({required this.model, required this.year, required this.color});

  Map<String, dynamic> toJson() {
    return {'model': model, 'year': year, 'color': color};
  }

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      model: json['model'],
      year: json['year'],
      color: json['color'],
    );
  }
}

class PlateSpotInfo {
  final String plateNumber; // ABC 123
  final String spotNumber; // 3 A

  PlateSpotInfo({required this.plateNumber, required this.spotNumber});

  Map<String, dynamic> toJson() {
    return {'plateNumber': plateNumber, 'spotNumber': spotNumber};
  }

  factory PlateSpotInfo.fromJson(Map<String, dynamic> json) {
    return PlateSpotInfo(
      plateNumber: json['plateNumber'],
      spotNumber: json['spotNumber'],
    );
  }
}
