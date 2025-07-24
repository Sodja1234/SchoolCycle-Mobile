import 'package:odc_mobile_template/business/models/announcement/announcement.dart';

class DetailAnnouncementState {
  final Announcement? announcement;
  final List<Announcement>? similarAnnouncements;
  final bool? isLoading;
  final String? errorMsg;

  DetailAnnouncementState({
    this.announcement,
    this.isLoading,
    this.errorMsg,
    this.similarAnnouncements
  });

  DetailAnnouncementState copyWith({
    Announcement? announcement,
    List<Announcement>? similarAnnouncements,
    bool? isLoading,
    String? errorMsg
  }){
    return DetailAnnouncementState(
      announcement : announcement ?? this.announcement,
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg ?? this.errorMsg,
      similarAnnouncements: similarAnnouncements ?? this.similarAnnouncements
    );
  }
}
