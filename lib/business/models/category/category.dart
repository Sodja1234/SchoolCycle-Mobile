import 'package:odc_mobile_template/business/models/photo/photo.dart';

class Category {
  final int id;
  final String? name;
  final String? description;
  final String? photo;

  Category({required this.id, this.name, this.description, this.photo});

  factory Category.fromJson(json) => Category(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    photo: json['photo']
  );

  Map toJson() => {'id': id, 'name': name, 'description': description,'photo' : photo};
}
