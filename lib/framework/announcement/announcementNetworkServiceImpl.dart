import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/business/models/announcement/createAnnouncement.dart';
import 'package:odc_mobile_template/business/models/user/authentication.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/framework/user/userNetworkServiceImpl.dart';
import 'package:odc_mobile_template/framework/utils/http/localHttpUtils.dart';
import 'package:odc_mobile_template/utils/http/HttpUtils.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AnnouncementNetworkServiceImpl implements AnnouncementNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  AnnouncementNetworkServiceImpl({
    required this.baseUrl,
    required this.httpUtils,
  });

  @override
  Future<List<Announcement>> getAnnouncements({
    List<String>? operationTypes,
    double? price,
    List<String>? states,
    List<String>? categories,
    int page = 1,
  }) async {
    var queryParams = <String, String>{'page': page.toString()};

    if (operationTypes != null && operationTypes.isNotEmpty) {
      queryParams['operation_type'] = operationTypes.join(',');
    }

    if (price != null) {
      queryParams['price'] = price.toString();
    }


    if (states != null && states.isNotEmpty) {
      queryParams['state'] = states.join(',');
    }

    if (categories != null && categories.isNotEmpty) {
      queryParams['category'] = categories.join(',');
    }

    var url = Uri.parse(
      "${baseUrl}",
    ).replace(path: 'api/announcements/public', queryParameters: queryParams);

    var response = await httpUtils.getData(url.toString());
    var listData = jsonDecode(response);
    var listAnnouncements = listData['data'];

    return listAnnouncements
        .map<Announcement>((e) => Announcement.fromJson(e))
        .toList();
  }

  @override
  Future<Announcement?> getAnnouncement(int id) async {
    var url = '$baseUrl/announcement/public/single/${id}';
    var response = await httpUtils.getData(url);
    var data = jsonDecode(response);
    var announcement = Announcement.fromJson(data);
    return announcement;
  }

  @override
  Future<bool> createAnnouncement(
    CreateAnnouncement announcement,
    String? token,
  ) async {
    var url = '$baseUrl/announcements';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['title'] = announcement.title;
    request.fields['description'] = announcement.description;
    request.fields['operation_type'] = announcement.operationType;
    request.fields['price'] = announcement.price?.toString() ?? '';
    request.fields['state'] = announcement.state;
    request.fields['exchange_location_address'] =
        announcement.exchangeLocationAddress;
    request.fields['exchange_location_lat'] =
        announcement.exchangeLocationLat.toString();
    request.fields['exchange_location_lng'] =
        announcement.exchangeLocationLng.toString();
    request.fields['category_id'] = announcement.categoryId.toString();
    request.fields['created_by'] = announcement.created_by.toString();

    // Ajout des photos si elles existent
    for (var photoPath in announcement.photos) {
      var file = File(photoPath);

      // Détection du type MIME (ex: image/png, image/webp, etc.)
      final mimeType = lookupMimeType(file.path); // ex: "image/png"
      final mimeSplit = mimeType?.split('/') ?? ['image', 'jpeg'];

      request.files.add(
        await http.MultipartFile.fromPath(
          'photos[]', // Le nom du champ dans le formulaire
          file.path,
          contentType: MediaType(
            mimeSplit[0],
            mimeSplit[1],
          ), // Type MIME de l'image
        ),
      );
    }
    // l'en -tête Authorization si le token est fourni
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Content-Type'] = 'multipart/form-data';

    // envoi de la requête
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // print(response.body);

    try {
      final body = json.decode(response.body);

      // Vérifie si une propriété "success" ou "message" indique une erreur
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (body['success'] == true || body['id'] != null) {
          print("Annonce créée avec succès");
          return true;
        } else {
          print("Échec  : ${body['message'] ?? body}");
          return false;
        }
      } else {
        print("Erreur côté serveur : ${body['message'] ?? body}");
        return false;
      }
    } catch (e) {
      print("Erreur de décodage JSON : $e");
      return false;
    }
  }

  @override
  Future<List<Announcement>> getAnnouncementByUser(String token) async{
    var url = '$baseUrl/announcements/user';
    print(url);
    var response = await httpUtils.getData(url,token: token);
    var listData = jsonDecode(response);
    var listAnnouncements = listData['data'];

    return listAnnouncements
        .map<Announcement>((e) => Announcement.fromJson(e))
        .toList();
  }

  

  @override
  Future<List<Announcement>> searchAnnouncements(String query) async{
    var url = '$baseUrl/announcements/public?search=${query}';
    print(url);
    var response = await httpUtils.getData(url);
    var listData = jsonDecode(response);
    var listAnnouncements = listData['data'];
    return listAnnouncements
        .map<Announcement>((e) => Announcement.fromJson(e))
        .toList();
  }
}

void main() async {
  var service = AnnouncementNetworkServiceImpl(
    baseUrl: "http://localhost:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  var auth = Authentication(email: "abc@gmail.com", password: "azertyuiop");
  var user = await UserNetworkServiceImpl(baseUrl: "http://localhost:8000/api", httpUtils: LocalHttpUtils()).seConnecter(auth);
  print(user!.token ?? "");
  var favorites = await service.getFavoriteAnnouncement(user!.token ?? "");
  print(favorites);

}
