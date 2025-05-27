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
  Future<List<Announcement>> getAnnouncements() async {
    var url = '$baseUrl/announcements';
    var response = await httpUtils.getData(url);
    var listData = jsonDecode(response);
    var listAnnouncements = listData['data'];
    listAnnouncements = listAnnouncements.map<Announcement>((e) => Announcement.fromJson(e)).toList();
    return listAnnouncements;
  }
}

void main() async {
  var service = AnnouncementNetworkServiceImpl(
    baseUrl: "http://127.0.0.1:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  var announcements = await service.getAnnouncements();
  for(var announement in announcements){
    print("---------------------------------------");
    print("titre : ${announement.title}");
    print("description : ${announement.description}");
    print("categorie : ${announement.category?.name}");
    print("Autheur : ${announement.created_by?.name}");
  }
}
