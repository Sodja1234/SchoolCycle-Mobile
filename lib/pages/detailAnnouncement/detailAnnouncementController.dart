import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/announcement/report.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/business/services/geolocation/geolocationService.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/detailAnnouncement/detailAnnouncementState.dart';

import '../../business/models/announcement/announcement.dart';

class DetailAnnouncementController
    extends StateNotifier<DetailAnnouncementState> {
  // Récupération du service d'annonces via GetIt (injection de dépendance)
  var announcementService = getIt.get<AnnouncementNetworkService>();
  var geolocationService = getIt.get<GeolocationService>();
  var userService = getIt.get<UserNetworkService>();

  DetailAnnouncementController() : super(DetailAnnouncementState()) {}

  Future<void> loadAnnouncementData(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      state = state.copyWith(isLoading: true);
      // Charge  l'annonce principale
      final announcement = await announcementService.getAnnouncement(id);
      print("l'annonce récuperé : ${announcement}");

      // Géocodage automatique si l'adresse existe
      if (announcement?.exchange_location_address?.isNotEmpty == true &&
          announcement?.exchange_location_lat == null) {
        await _geocodeAddress(announcement!.exchange_location_address!);
      }

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

  Future<void> _geocodeAddress(String address) async {
    if (address.isEmpty || state.announcement == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final coordinates = await geolocationService.geocodeAddress(address);
      if (coordinates == null) return;
      final jsonData = state.announcement!.toJson();
      final updatedJson = {
        ...jsonData, // Spread operator pour copier toutes les valeurs existantes
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      };
      final updatedAnnouncement = Announcement.fromJson(updatedJson);
      state = state.copyWith(
        announcement: updatedAnnouncement,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      // 8. Gestion d'erreur détaillée
      debugPrint('Erreur de géocodage: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMsg: 'Échec du géocodage: ${e.toString()}',
      );
    }
  }

  Future<bool> reportAnnouncement(Report data,String token) async{
    state = state.copyWith(isLoading: true);
    try {
      await announcementService.reportAnnouncement(data, token);
      state = state.copyWith(isLoading: false, alreadyReported: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMsg: e.toString());
      return false;
    }
  }
}

// Provider Riverpod pour exposer le contrôleur et son état à l'application
final DetailAnnouncementProvider = StateNotifierProvider<
  DetailAnnouncementController,
  DetailAnnouncementState
>((ref) => DetailAnnouncementController());
