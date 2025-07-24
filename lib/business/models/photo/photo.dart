class Photo {
  final int id;
  final int announcementId;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  Photo({
    required this.id,
    required this.announcementId,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      announcementId: json['announcement_id'],
      url: json['url'] ?? '',
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
      updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'announcement_id': announcementId,
      'url': url,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
