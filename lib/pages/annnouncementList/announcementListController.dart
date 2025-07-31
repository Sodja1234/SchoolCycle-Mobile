import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/annnouncementList/announcementListState.dart';

class AnnouncementListController extends StateNotifier<AnnoucementListState>{

  var announcementService = getIt.get<AnnouncementNetworkService>();

  AnnouncementListController() : super(AnnoucementListState());

  // Charge les annonces initiales
  Future<void> loadInitialAnnouncements({
    List<String>? operationTypes,
    List<String>? states,
    List<String>? categories,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final announcements = await announcementService.getAnnouncements(
        operationTypes: operationTypes,
        states: states,
        categories: categories,
      );

      state = state.copyWith(
        announcements: announcements,
        isLoading: false,
        page: 1,
        hasMore: announcements.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des annonces',
      );
    }
  }


  // Charge plus d'annonces (pour le scroll infini)
  Future<void> loadMoreAnnouncements({
    List<String>? operationTypes,
    List<String>? states,
    List<String>? categories,
  }) async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);

      final newAnnouncements = await announcementService.getAnnouncements(
        operationTypes: operationTypes,
        states: states,
        categories: categories,
      );

      state = state.copyWith(
        announcements: [...?state.announcements, ...newAnnouncements],
        isLoading: false,
        page: state.page + 1,
        hasMore: newAnnouncements.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement supplémentaire',
      );
    }
  }
}

final announcementListControllerProvider = StateNotifierProvider<AnnouncementListController, AnnoucementListState>((ref) {
  return AnnouncementListController();
});