import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/business/services/user/userLocalService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/auth/login/loginState.dart';
import 'package:odc_mobile_template/pages/intro/appCtrl.dart';
import 'package:odc_mobile_template/pages/profils/profil/profileState.dart';
import 'package:path/path.dart';

class ProfilController extends StateNotifier<ProfilState> {
  var announcementService = getIt.get<AnnouncementNetworkService>();
  var userLocalService = getIt.get<UserLocalService>();
  final Ref ref;

  ProfilController({required this.ref}) : super(ProfilState()) {
    _init();
  }


  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = ref.read(LoginCtrlProvider).user;
      if (user != null && user.token != null) {
        await Future.wait([
          getAnnouncements(user.token!),
          getFavoritesAnnouncements(user.token!),
        ]);
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Erreur lors du chargement initial",
      );
    }
  }

  Future<void> getAnnouncements(String token) async {
    if (state.isLoading ?? true) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final announcements = await announcementService.getAnnouncementByUser(
        token,
      );
      state = state.copyWith(announcements: announcements, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Erreur lors du chargement des annonces",
        isLoading: false,
      );
    }
  }

  Future<void> getFavoritesAnnouncements(String token) async {
    if (state.isLoading ?? true) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final announcements = await announcementService.getFavoriteAnnouncement(
        token,
      );
      state = state.copyWith(
        announcementFavorites: announcements,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: "Erreur lors du chargement des annonces",
        isLoading: false,
      );
    }
  }
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await userLocalService.supprimerUser();
      await ref.read(LoginCtrlProvider.notifier).supprimerUserLocal();
      await ref.read(appCtrlProvider.notifier).clearUser();
      state = ProfilState(); // Réinitialisation COMPLÈTE de l'état
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Erreur lors de la déconnexion: ${e.toString()}",
      );
    }
  }

  Future<void> searchFavoriteAnnouncements(String query, String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final allFavorites = await announcementService.getFavoriteAnnouncement(
        token,
      );
      final filtered =
          allFavorites.where((announcement) {
            return query.isEmpty ||
                (announcement.title?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ==
                    true) ||
                (announcement.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ==
                    true);
          }).toList();

      state = state.copyWith(announcementFavorites: filtered, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Erreur lors de la recherche dans les favoris",
        isLoading: false,
      );
    }
  }


  Future<void> refresh() async {
    final user = ref.read(LoginCtrlProvider).user;
    if (user?.token != null) {
      await getAnnouncements(user!.token!);
      await getFavoritesAnnouncements(user.token!);
    }
  }

  Future<void> searchUserAnnouncements(String query, String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final allAnnouncements = await announcementService.getAnnouncementByUser(
        token,
      );
      final filtered =
          allAnnouncements.where((announcement) {
            return query.isEmpty ||
                (announcement.title?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ==
                    true) ||
                (announcement.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ==
                    true);
          }).toList();

      state = state.copyWith(announcements: filtered, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Erreur lors de la recherche",
        isLoading: false,
      );
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfilController, ProfilState>(
      (ref) => ProfilController(ref: ref),
    );
