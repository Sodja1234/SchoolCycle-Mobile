import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/detailAnnouncement/detailAnnouncementState.dart';

class DetailAnnouncementController extends StateNotifier<DetailAnnouncementState> {
  // Récupération du service d'annonces via GetIt (injection de dépendance)
  var announcementService = getIt.get<AnnouncementNetworkService>();

  DetailAnnouncementController() : super(DetailAnnouncementState()) {}

  Future<void> loadAnnouncementData(int id) async {
    state = state.copyWith(isLoading: true);
    try {

      state = state.copyWith(isLoading: true);
      // Charge  l'annonce principale
      final announcement = await announcementService.getAnnouncement(id);
      print("l'annonce récuperé : ${announcement}");


      // Récupère les annonces similaires (maximum 10) appartenant à la même catégorie
      // Si moins de 10 annonces sont disponibles, retourne toutes celles trouvées
      final similar = await announcementService.getAnnouncements(
        categories: [announcement!.category!.name ?? ''],
      );

      var similarFiltered =
          similar
              .where((a) => a.id != id) // Exclure l'annonce actuelle
              .toList();

      // Mélanger la liste pour recuperer les annonces de façon aleatoire
      similarFiltered.shuffle(Random());

      // Prendre maximum 10 annonces
      if (similarFiltered.length > 10) {
        similarFiltered = similarFiltered.sublist(0, 10);
      }

      state = state.copyWith(
        announcement: announcement,
        similarAnnouncements: similarFiltered,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMsg: e.toString());
    }
  }
}

// Provider Riverpod pour exposer le contrôleur et son état à l'application
final DetailAnnouncementProvider = StateNotifierProvider<
  DetailAnnouncementController,
  DetailAnnouncementState
>((ref) => DetailAnnouncementController());
