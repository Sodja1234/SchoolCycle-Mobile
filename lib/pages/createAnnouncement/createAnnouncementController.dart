import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/announcement/createAnnouncement.dart';
import 'package:odc_mobile_template/business/services/announcement/announcementNetworkService.dart';
import 'package:odc_mobile_template/business/services/category/categoryNetworkService.dart';
import 'package:odc_mobile_template/business/services/geolocation/geolocationService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/annnouncementList/announcementListController.dart';
import 'package:odc_mobile_template/pages/createAnnouncement/createAnnouncementState.dart';
import 'package:latlong2/latlong.dart';
import 'package:odc_mobile_template/pages/home/homeCtrl.dart';

class CreateAnnouncementController
    extends StateNotifier<CreateAnnouncementState> {
  var categoriesService = getIt.get<CategoryNetworkService>();
  var geolocationService = getIt.get<GeolocationService>();
  var announcementService = getIt.get<AnnouncementNetworkService>();
  final Ref ref;

  CreateAnnouncementController(this.ref) : super(CreateAnnouncementState()) {
    init();
  }

  Future<void> init() async {
    // Initialisation de l'état
    // Chargement des catégories
    await getCategories();
  }

  Future<bool> createAnnouncement(CreateAnnouncement data, String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await announcementService.createAnnouncement(data, token);

      if (success) {
        state = state.copyWith(isLoading: false);
        ref.read(homeCtrlProvider.notifier).loadAnnouncements();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Échec de la création de l'annonce",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erreur : ${e.toString()}",
      );
      return false;
    }
  }

  // Methode pour obtenir les categories
  Future<void> getCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      var categories = await categoriesService.getCategories();
      print(categories);
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleMapVisibility() {
    state = state.copyWith(showMap: !(state.showMap ?? false));
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoadingLocation: true, errorMessage: null);
    try {
      var location = await geolocationService.getCurrentLocation();
      var address = await geolocationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      state = state.copyWith(
        currentLocation: LatLng(location.latitude, location.longitude),
        addressController: TextEditingController(text: address),
        latitudeController: TextEditingController(
          text: location.latitude.toString(),
        ),
        longitudeController: TextEditingController(
          text: location.longitude.toString(),
        ),
        isLoadingLocation: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchAddress(String query) async {
    state = state.copyWith(isLoadingLocation: true, errorMessage: null);
    try {
      var location = await geolocationService.searchAddress(query);
      state = state.copyWith(
        selectedLocation: LatLng(location.latitude, location.longitude),
        addressController: TextEditingController(text: location.address),
        latitudeController: TextEditingController(
          text: location.latitude.toString(),
        ),
        longitudeController: TextEditingController(
          text: location.longitude.toString(),
        ),
        isLoadingLocation: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> getSelectedLocation() async {
    if (state.selectedLocation == null) {
      state = state.copyWith(
        errorMessage: 'Veuillez sélectionner une localisation',
      );
      return;
    }
    state = state.copyWith(isLoadingLocation: true, errorMessage: null);
    try {
      var address = await geolocationService.getAddressFromCoordinates(
        state.selectedLocation!.latitude,
        state.selectedLocation!.longitude,
      );
      state = state.copyWith(
        addressController: TextEditingController(text: address),
        latitudeController: TextEditingController(
          text: state.selectedLocation!.latitude.toString(),
        ),
        longitudeController: TextEditingController(
          text: state.selectedLocation!.longitude.toString(),
        ),
        isLoadingLocation: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final createAnnouncementProvider = StateNotifierProvider<
  CreateAnnouncementController,
  CreateAnnouncementState
>((ref) => CreateAnnouncementController(ref));
