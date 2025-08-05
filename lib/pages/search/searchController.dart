import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/search/searchState.dart';

class SearchController extends StateNotifier<SearchState>{
  var announcementService = getIt.get<AnnouncementNetworkService>();
  SearchController() : super(SearchState());

  Future<void> searchAnnouncement(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        searchResults: [],
        searchQuery: query,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null, // Réinitialiser l'erreur à chaque nouvelle recherche
      searchQuery: query,
    );

    try {
      final announcements = await announcementService.searchAnnouncements(query);
      state = state.copyWith(
        searchResults: announcements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // methode pour vider les resultats
  void clearResults() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
    );
  }
}

final searchControllerProvider = StateNotifierProvider<SearchController,SearchState>((ref) => SearchController());