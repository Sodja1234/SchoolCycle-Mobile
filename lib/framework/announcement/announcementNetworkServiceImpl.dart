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
    ).replace(path: 'api/announcements', queryParameters: queryParams);

    var response = await httpUtils.getData(url.toString());
    var listData = jsonDecode(response);
    var listAnnouncements = listData['data'];

    return listAnnouncements
        .map<Announcement>((e) => Announcement.fromJson(e))
        .toList();
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
    baseUrl: "http://localhost:8000/api",
    httpUtils: LocalHttpUtils(),
  );
}
