import 'dart:convert';

import 'package:odc_mobile_template/business/models/chat/chat.dart';
import 'package:odc_mobile_template/business/models/chat/message.dart';
import 'package:odc_mobile_template/business/models/user/authentication.dart';
import 'package:odc_mobile_template/business/services/chat/chatNetworkService.dart';
import 'package:odc_mobile_template/framework/user/userNetworkServiceImpl.dart';
import 'package:odc_mobile_template/framework/utils/http/localHttpUtils.dart';
import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';
import 'package:odc_mobile_template/utils/http/HttpUtils.dart';

class ChatNetworkServiceImpl implements ChatNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  ChatNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  HttpRequestException _handleHttpError(HttpRequestException e) {
    final code = e.statusCode;
    dynamic message;

    try {
      final body = jsonDecode(e.body ?? '{}');
      message =
          body['error'] ??
          body['message'] ??
          body['detail'] ??
          (body['erros'] is Map
              ? (body['erros'] as Map).values.firstOrNull?.first
              : null) ??
          'une erreur inconnu est survenue';
    } catch (_) {
      message = 'Une erreur inconnu est survenue';
    }
    return HttpRequestException(code, message.toString(), e.body);
  }

  @override
  Future<List<Chat>> getChats(String token) async {
    final url = '$baseUrl/my-chats';
    try {
      final response = await httpUtils.getData(url, token: token);
      final data = jsonDecode(response)['data'] as List;
      print(data);
      // for (var i = 0; i < data.length; i++) {
      //   print('Message $i : ${data[i]}');
      // }
      return data.map((json) => Chat.fromJson(json)).toList();
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        'Erreur lors du chargement des conversations',
        e.toString(),
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getContactInfo(int chat_id, String token) async {
    final url = '$baseUrl/chats/$chat_id/contact-info';
    try {
      final response = await httpUtils.getData(url, token: token);
      return jsonDecode(response) as Map<String, dynamic>;
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        'Erreur lors de la récupération des infos de conatact',
        e.toString(),
      );
    }
  }

  @override
  Future<Message> sendMessage({
    required int conversation,
    required String content,
    required String token,
  }) async {
    final url = '$baseUrl/chats/$conversation/messages';
    try {
      final response = await httpUtils.postData(
        url,
        body: {'content': content},
        token: token
      );
      return Message.fromJson(jsonDecode(response));
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        "Erreur lors de l'envoie du message",
        e.toString(),
      );
    }
  }

  @override
  Future<Chat> createChat({
    required int posted_by,
    required String content,
    required String token,
  }) async {
    final url = '$baseUrl/announcements/$posted_by/chats';
    try {
      final response = await httpUtils.postData(
        url,
        body: {'content': content},
        token: token
      );
      print("Retour chat créer : $response");
      return Chat.fromJson(jsonDecode(response));
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        'Erreur lors de la création du chat',
        e.toString(),
      );
    }
  }

  @override
  Future<bool> closeChat(int chat_id, String token) async {
    final url = '$baseUrl/chats/$chat_id/close';
    try {
      await httpUtils.postData(url, token: token);
      return true;
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        'Erreur lors de la clôture du chat',
        e.toString(),
      );
    }
  }

  @override
  Future<List<Message>> getMessagesForChat(int chat_id, String token) async {
    final url = '$baseUrl/chats/$chat_id/messages';
    try {
      final response = await httpUtils.getData(url, token: token);
      final data = jsonDecode(response) as List;
      return data.map((json) => Message.fromJson(json)).toList();
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        'Erreur lors du chargement des messages',
        e.toString(),
      );
    }
  }

  @override
  Future<List<Chat>> getChatsForAnnouncement(int announcementId, String token) async {
    final url = '$baseUrl/announcements/$announcementId/user-chat';
    try {
      final response = await httpUtils.getData(url, token: token);
      final data = jsonDecode(response) as List;
      return data.map((json) => Chat.fromJson(json)).toList();
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        "Erreur lors de la récupération du chat pour l'annonce",
        e.toString(),
      );
    }
  }

  @override
  Future<Chat?> getUserChatForAnnouncement(int announcementId, String token) async {
    final url = '$baseUrl/announcements/$announcementId/user-chat';
    try {
      final response = await httpUtils.getData(url,token: token);
      final data = jsonDecode(response)['data'] as List;
      if (data.isEmpty) {
        return null;
      }
      return Chat.fromJson(data[0]);
    } on HttpRequestException catch (e) {
      throw _handleHttpError(e);
    } catch (e) {
      throw HttpRequestException(
        500,
        "Erreur lors de la récupération du chat pour l'annonce",
        e.toString(),
      );
    }
  }
}
void main() async {
  final String baseUrl = 'http://10.252.252.9:8000/api';

  // Étape 1 : Authentification utilisateur
  var auth = Authentication(email: 'stanislas@gmail.com', password: '123456789');
  var user = await UserNetworkServiceImpl(
    baseUrl: baseUrl,
    httpUtils: LocalHttpUtils(),
  ).seConnecter(auth);

  // Étape 2 : Initialisation du service de chat
  final chatService = ChatNetworkServiceImpl(
    baseUrl: baseUrl,
    httpUtils: LocalHttpUtils(),
  );

  // Étape 3 : Test de création du chat
  try {
    print('[Create Chat]');
    final chat = await chatService.createChat(
      posted_by: 4,
      content: "Bonjour, je suis intéressé par votre annonce.",
      token: user?.token ?? "",
    );

    // Affichage des informations du chat créé
    print("Chat créé avec succès :");
    print("ID : ${chat.id}");
    print("Créé par : ${chat.createdBy}");
    //print("Annonce : ${chat.postedBy.title} (par ${chat.postedBy.createdBy})");
    print("Fermé : ${chat.isClosed}");
    print("Messages : ${chat.messages.length}");
  } catch (e) {
    print('Erreur lors de la création du chat : $e');
  }
}




