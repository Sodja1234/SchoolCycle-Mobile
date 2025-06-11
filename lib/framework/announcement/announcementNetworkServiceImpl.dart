import 'dart:async';
import 'dart:convert';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/framework/utils/http/localHttpUtils.dart';
import 'package:odc_mobile_template/utils/http/HttpUtils.dart';

class AnnouncementNetworkServiceImpl implements AnnouncementNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  AnnouncementNetworkServiceImpl({
    required this.baseUrl,
    required this.httpUtils,
  });

  @override
  Future<List<Announcement>> getAnnouncements({
    List<String>? operationTypes, // Liste des types d'opérations (ex: don, echange, vente) en filtre optionnel
    double? price, // Prix maximum pour filtrer les annonces (optionnel)
    List<String>? states, // Liste des états (state) pour filtrer les annonces (optionnel)
  }) async {
    var queryParams = <String, String>{};  // // Initialisation d'un map pour stocker les paramètres de la requête


    // // Si la liste des types d'opérations n'est pas vide, on la transforme en chaîne séparée par des virgules
    if (operationTypes != null && operationTypes.isNotEmpty) {
      queryParams['operation_type'] = operationTypes.join(',');
    }


    // Si un prix max est défini, on l'ajoute dans les paramètres sous forme de chaîne
    if (price != null) {
      queryParams['price'] = price.toString();
    }


    // Si la liste des états n'est pas vide, on la transforme aussi en chaîne séparée par des virgules
    if (states != null && states.isNotEmpty) {
      queryParams['state'] = states.join(',');
    }

    var url = Uri.parse("${baseUrl}").replace(
      path: 'api/announcements',
      queryParameters: queryParams // Paramètres GET encodés dans l'URL
    );
    var response = await httpUtils.getData(url.toString());
    var listData = jsonDecode(response);
    var listAnnouncements = listData['data'];
    listAnnouncements =
        listAnnouncements
            .map<Announcement>((e) => Announcement.fromJson(e))
            .toList();
    return listAnnouncements;
  }

  @override
  Future<Announcement?> getAnnouncement(int id) async {
    var url = '$baseUrl/announcements/${id}';
    var response = await httpUtils.getData(url);
    var data = jsonDecode(response);
    var announcement = Announcement.fromJson(data);
    return announcement;
  }
}

void main() async {
  var service = AnnouncementNetworkServiceImpl(
    baseUrl: "http://127.0.0.1:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  var announcements = await service.getAnnouncements();
  for(var announcement in announcements){
    print("---------------------------");
    print(announcement.title);
    print(announcement.operation_type);
    print(announcement.price);
    print("-----Fin-------------");
  }
}
