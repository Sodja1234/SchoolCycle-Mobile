import 'package:odc_mobile_template/business/models/announcement/announcement.dart';

abstract class AnnouncementNetworkService {
  Future<List<Announcement>> getAnnouncements();
  Future<Announcement?> getAnnouncement(int id);
}
