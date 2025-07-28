import 'package:odc_mobile_template/business/models/user/user.dart';

class Message {
  final int id;
  final int conversation;
  final User sender;
  final User receiver;
  final String content;
  final String createdAt;

  Message({
    required this.id,
    required this.conversation,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    conversation: json['conversation'],
    sender: User.fromJson(json['sender']),     // transforme le JSON en User
    receiver: User.fromJson(json['receiver']), // idem
    content: json['content'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation': conversation,
    'sender': sender.toJson(),
    'receiver': receiver.toJson(),
    'content': content,
    'created_at': createdAt,
  };
}
