class Category {
  final int id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(json) => Category(
    id: json['id'],
    name: json['name'],
    description: json['description'],
  );

  Map toJson() => {
    'id' : id,
    'name' : name,
    'description' : description
  };
}
