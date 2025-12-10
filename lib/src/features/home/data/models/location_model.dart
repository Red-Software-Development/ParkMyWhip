class LocationModel {
  final String id; // unique ID from backend
  final String title; // header text
  final String description; // small description

  LocationModel({
    required this.id,
    required this.title,
    required this.description,
  });

  // For backend JSON mapping
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description};
  }
}
