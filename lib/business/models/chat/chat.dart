import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/business/models/chat/message.dart';
class Chat {
  final int id;
  final int createdBy;
  final Announcement postedBy;
  final bool isClosed;
  final String? closedAt;
  final String? closeTo;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.createdBy,
    required this.postedBy,
    required this.isClosed,
    this.closedAt,
    this.closeTo,
    required this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final postedByJson = json['posted_by'] ?? {};


    final AnnouncementMinimal = {
      'id': postedByJson['id'],
      'title': postedByJson['title'],
      'description': null,
      'operation_type': null,
      'price': null,
      'isComplete': null,
      'isCanceled': null,
      'exchangeLocationAddress': null,
      'exchangeLocationLng': null,
      'exchangeLocationLat': null,
      'category': null,
      'photos': null,
      'created_by': postedByJson['created_by'] != null
          ? {'name': postedByJson['created_by']}
          : null,
    };

    return Chat(
      id: json['id'],
      createdBy: json['created_by'],
      postedBy: Announcement.fromJson(AnnouncementMinimal),
      isClosed: json['is_closed'],
      closedAt: json['closed_at'],
      closeTo: json['close_to'],
      messages: (json['messages'] as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_by': createdBy,
    'posted_by': {
      'id': postedBy.id,
      'title': postedBy.title,
      'created_by': postedBy.created_by?.name,
    },
    'is_closed': isClosed,
    'closed_at': closedAt,
    'close_to': closeTo,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}