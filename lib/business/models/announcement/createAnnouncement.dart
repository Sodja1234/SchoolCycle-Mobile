class CreateAnnouncement {
  final String title;
  final String description;
  final String operationType;
  final int? price;
  final String state;
  final String exchangeLocationAddress;
  final double exchangeLocationLat;
  final double exchangeLocationLng;
  final int categoryId;
  final int created_by;
  final List<String> photos;

  CreateAnnouncement({
    required this.title,
    required this.description,
    required this.operationType,
    this.price,
    required this.state,
    required this.exchangeLocationAddress,
    required this.exchangeLocationLat,
    required this.exchangeLocationLng,
    required this.categoryId,
    required this.created_by,
    required this.photos,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'operation_type': operationType,
    'price': price,
    'state' : state,
    'exchange_location_address': exchangeLocationAddress,
    'exchange_location_lat': exchangeLocationLat,
    'exchange_location_lng': exchangeLocationLng,
    'category_id': categoryId,
    'created_by': created_by,
    'photos': photos,
  };
}
