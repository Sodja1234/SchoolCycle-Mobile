import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/business/models/announcement/createAnnouncement.dart';

abstract class AnnouncementNetworkService {
  Future<List<Announcement>> getAnnouncements({List<String>? operationTypes,double? price,List<String>? states,List<String>? categories});
  Future<Announcement?> getAnnouncement(int id);
  Future<bool> createAnnouncement(CreateAnnouncement announcement,String? token);
  Future<List<Announcement>> getAnnouncementByUser(String token);
  Future<List<Announcement>> getFavoriteAnnouncement(String token);
  Future<List<Announcement>> searchAnnouncements(String query);
}
