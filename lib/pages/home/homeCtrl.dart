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

  // Récupérer annonces filtrées par type d'opération
  Future<void> getAnnouncementsfilter(String operationType) async {
    state = state.copyWith(isLoading: true);
    try {
      var announcements = await announcementService.getAnnouncements(
        operationTypes: [operationType],
      );
      switch (operationType) {
        case 'sale':
          state = state.copyWith(
            salesAnnouncements: announcements,
            isLoading: false,
          );
          break;
        case 'don':
          state = state.copyWith(
            donationAnnouncements: announcements,
            isLoading: false,
          );
          break;
        case 'exchange':
          state = state.copyWith(
            exchangeAnnouncements: announcements,
            isLoading: false,
          );
          break;
        default:
          state = state.copyWith(errorMessage: "Une erreur est survenue");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final homeCtrlProvider = StateNotifierProvider<Homectrl, Homestate>((ref) {
  return Homectrl();
});
