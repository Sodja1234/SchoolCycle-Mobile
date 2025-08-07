import 'package:odc_mobile_template/business/models/user/user.dart';

class Profile {
  final int? id;
  final User? user;
  final String? bio;
  final String? telephone;
  final String? avatar;
  final String? adresse;
  final String? profession;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    this.id,
    this.user,
    this.adresse,
    this.avatar,
    this.bio,
    this.profession,
    this.telephone,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      adresse: json['adresse'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      profession: json['profession'] as String?,
      telephone: json['telephone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'bio': bio,
      'telephone': telephone,
      'avatar': avatar,
      'adresse': adresse,
      'profession': profession,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}