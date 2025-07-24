import 'package:odc_mobile_template/business/models/photo/photo.dart';

class Category {
  final int id;
  final String? name;
  final String? description;
  final Photo? image;

  Category({required this.id, this.name, this.description, this.image});

  factory Category.fromJson(json) => Category(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    image: json['image']
  );

  Map toJson() => {'id': id, 'name': name, 'description': description,'image' : image};
}
