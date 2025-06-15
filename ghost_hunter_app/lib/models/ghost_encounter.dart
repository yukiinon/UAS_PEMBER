class GhostEncounter {
  final String id;
  final String ghostName;
  final String description;
  final String location;
  final DateTime timestamp;
  final String? photoPath;
  final String activityLevel;

  GhostEncounter({
    required this.id,
    required this.ghostName,
    required this.description,
    required this.location,
    required this.timestamp,
    this.photoPath,
    required this.activityLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ghostName': ghostName,
      'description': description,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'photoPath': photoPath,
      'activityLevel': activityLevel,
    };
  }

  factory GhostEncounter.fromJson(Map<String, dynamic> json) {
    return GhostEncounter(
      id: json['id'],
      ghostName: json['ghostName'],
      description: json['description'],
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp']),
      photoPath: json['photoPath'],
      activityLevel: json['activityLevel'],
    );
  }
}