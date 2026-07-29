class LocationModel {
  final double lat;
  final double lng;
  final String? label;

  const LocationModel({
    required this.lat,
    required this.lng,
    this.label,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'label': label,
    };
  }
}
