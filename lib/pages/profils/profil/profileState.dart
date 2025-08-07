import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import '../../../business/models/user/user.dart';

class ProfilState{
  final bool isLoading;
  final String? error;
  final User? user;
  final List<Announcement>? announcements;
  final List<Announcement>? announcementFavorites;

  ProfilState({
    this.isLoading = false,
    this.announcements,
    this.error,
    this.user,
    this.announcementFavorites,
  });

  ProfilState copyWith({
    bool? isLoading,
    String? error,
     User? user,
     List<Announcement>? announcements,
     List<Announcement>? announcementFavorites
  }){
    return ProfilState(
      isLoading: isLoading ??this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      announcements: announcements ?? this.announcements,
      announcementFavorites: announcementFavorites ?? this.announcementFavorites
    );
  }
}

