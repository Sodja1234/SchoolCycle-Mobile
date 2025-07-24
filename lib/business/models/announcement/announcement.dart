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
  final String? exchangeLocationAddress;
  final double? exchangeLocationLng;
  final double? exchangeLocationLat;
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
    this.exchangeLocationAddress,
    this.exchangeLocationLng,
    this.exchangeLocationLat,
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
    isComplete: json['isComplete'],
    isCanceled: json['isCanceled'],
    exchangeLocationAddress: json['exchangeLocationAddress'],
    exchangeLocationLng: json['exchangeLocationLng'],
    exchangeLocationLat: json['exchangeLocationLat'],
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
    'isCanceled': isCanceled,
    'exchangeLocationAddress': exchangeLocationAddress,
    'exchangeLocationLng': exchangeLocationLng,
    'exchangeLocationLat': exchangeLocationLat,
    'category': category,
    'photos': photos,
    'created_by': created_by,
    'created_at' : created_at
  };
}
