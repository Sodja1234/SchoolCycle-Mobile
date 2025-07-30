class Geolocation {
  final String address;
  final double latitude;
  final double longitude;

  Geolocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Geolocation.fromJson(Map<String, dynamic> json) {
    return Geolocation(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}