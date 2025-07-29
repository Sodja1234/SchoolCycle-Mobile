import 'package:odc_mobile_template/business/models/chat/chat.dart';
import 'package:odc_mobile_template/business/models/chat/message.dart';

abstract class ChatNetworkService{
  //Récupère toutes les conversations de l'utilisateur courant
  Future<List<Chat>> getChats(String token);

  //Envoi un message dans une conversation
  Future<Message> sendMessage({
    required int conversation,
    required String content,
    required String token
  });


  //Créer un chat pour une annonce
  Future<Chat>createChat({
    required int posted_by,
    required String content,
    required String token
});

  //Clôurer un chat et l'annonce lié
  Future<bool> closeChat(int chat_id, String token);

  //Récupère tous les messages d'une conversation
  Future<List<Message>> getMessagesForChat(int chat_id, String token);

  //Récupère les informations de contact pour un chat
  Future<Map<String, dynamic>> getContactInfo(int chat_id, String token);

  //Récupère le chat existant pour une annonce spécifique de l'utilisateur
  Future<Chat?> getUserChatForAnnouncement(int announcementId, String token);

  //Récupère tous les chats liés à une annonce
  Future<List<Chat>> getChatsForAnnouncement(int announcementId, String token);


}