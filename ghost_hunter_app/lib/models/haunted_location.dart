class HauntedLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String activityLevel;
  final String icon;

  HauntedLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.activityLevel,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'activityLevel': activityLevel,
      'icon': icon,
    };
  }

  factory HauntedLocation.fromJson(Map<String, dynamic> json) {
    return HauntedLocation(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
      activityLevel: json['activityLevel'],
      icon: json['icon'],
    );
  }
}