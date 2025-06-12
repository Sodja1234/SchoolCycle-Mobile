import 'package:odc_mobile_template/business/models/announcement/announcement.dart';

abstract class AnnouncementNetworkService {
  Future<List<Announcement>> getAnnouncements({List<String>? operationTypes,double? price,List<String>? states});
  Future<Announcement?> getAnnouncement(int id);
}
