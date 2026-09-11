class LocationSearchResultModel {
  final int? id;
  final String name;
  final String? district;
  final String? state;
  final String country;
  final double latitude;
  final double longitude;
  final double? elevation;
  final bool isVillage;
  final String displayName;

  LocationSearchResultModel({
    this.id,
    required this.name,
    this.district,
    this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.isVillage,
    required this.displayName,
  });

  factory LocationSearchResultModel.fromJson(Map<String, dynamic> json) {
    return LocationSearchResultModel(
      id: json['id'],
      name: json['name'] ?? '',
      district: json['district'],
      state: json['state'],
      country: json['country'] ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      elevation: (json['elevation'] as num?)?.toDouble(),
      isVillage: json['is_village'] ?? false,
      displayName: json['display_name'] ?? json['name'] ?? '',
    );
  }
}

class SavedLocationModel {
  final int id;
  final String name;
  final String? district;
  final String? state;
  final String country;
  final double latitude;
  final double longitude;
  final double? elevation;
  final bool isVillage;
  final bool isFavorite;

  SavedLocationModel({
    required this.id,
    required this.name,
    this.district,
    this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.isVillage,
    required this.isFavorite,
  });

  factory SavedLocationModel.fromJson(Map<String, dynamic> json) {
    return SavedLocationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      district: json['district'],
      state: json['state'],
      country: json['country'] ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      elevation: (json['elevation'] as num?)?.toDouble(),
      isVillage: json['is_village'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'is_village': isVillage,
      'is_favorite': isFavorite,
    };
  }
}
