import 'package:odc_mobile_template/business/models/category/category.dart';
import 'package:odc_mobile_template/business/models/photo/photo.dart';
import 'package:odc_mobile_template/business/models/user/user.dart';

class Announcement {
  final int id;
  final String? title;
  final String? description;
  final String? operation_type;
  final int? price;
  final bool? isComplete;
  final bool? isCanceled;
  final String? exchange_location_address;
  final String? exchange_location_lng;
  final String? exchange_location_lat;
  final String? state;
  final Category? category;
  final List<Photo>? photos;
  final User? created_by;
  final String? created_at;

  Announcement({
    required this.id,
    this.title,
    this.description,
    this.operation_type,
    this.price,
    this.isComplete,
    this.isCanceled,
    this.state,
    this.exchange_location_address,
    this.exchange_location_lng,
    this.exchange_location_lat,
    this.category,
    this.photos,
    this.created_by,
    this.created_at,
  });

  factory Announcement.fromJson(json) => Announcement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    operation_type: json['operation_type'],
    price: json['price'],
    state: json['state'],
    isComplete: json['isComplete'],
    isCanceled: json['isCanceled'],
    exchange_location_address: json['exchange_location_address'],
    exchange_location_lng: json['exchange_location_lng'],
    exchange_location_lat: json['exchange_location_lat'],
    category: json['category'] != null ? Category.fromJson(json['category'] as Map<String, dynamic>) : null,
    photos: json['photos'] != null
        ? (json['photos'] as List)
            .map((photo) => Photo.fromJson(photo as Map<String, dynamic>))
            .toList()
        : [],
    created_by: json['created_by'] != null
        ? User.fromJson(json['created_by'] as Map<String, dynamic>)
        : null,
    created_at: json['created_at'],
  );

  Map toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'operation_type': operation_type,
    'price': price,
    'isComplete': isComplete,
    'state': state,
    'isCanceled': isCanceled,
    'exchange_location_address': exchange_location_address,
    'exchange_location_lng': exchange_location_lng,
    'exchange_location_lat': exchange_location_lat,
    'category': category,
    'photos': photos,
    'created_by': created_by,
    'created_at' : created_at
  };
}
