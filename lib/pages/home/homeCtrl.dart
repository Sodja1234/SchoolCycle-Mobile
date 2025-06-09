import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/home/homeState.dart';

class Homectrl extends StateNotifier<Homestate> {
  var announcementService = getIt<AnnouncementNetworkService>();

  Homectrl() : super(Homestate()) {
    getAnnouncements();
  }

  Future<void> getAnnouncements() async {
    state = state.copyWith(isLoading: true);
    try {
      var announcements = await announcementService.getAnnouncements();
      print("test");
      state = state.copyWith(announcements: announcements, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      print("error : $e");
    }
  }

}

final homeCtrlProvider = StateNotifierProvider<Homectrl, Homestate>((ref) {
  return Homectrl();
});
