import 'dart:io';
import 'package:flutter/material.dart';
import 'package:odc_mobile_template/business/models/category/category.dart';
import 'package:latlong2/latlong.dart';

class CreateAnnouncementState {
  final bool? isLoading;
  final String? errorMessage;
  final List<Category>? categories;
  final bool? isLoadingLocation;
  final String selectedType;
  final bool? showMap;
  final LatLng? selectedLocation;
  final LatLng? currentLocation;
  final TextEditingController? latitudeController;
  final TextEditingController? longitudeController;

  CreateAnnouncementState({
    this.categories,
    this.isLoading,
    this.errorMessage,
    this.isLoadingLocation,
    this.selectedType = 'sale', // Default type is 'sale'
    this.showMap,
    this.selectedLocation,
    this.currentLocation,
    this.latitudeController,
    this.longitudeController
  });

  CreateAnnouncementState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Category>? categories,
    bool? isLoadingLocation,
    String? selectedType,
    bool? showMap,
    List<File>? selectedImages,
    LatLng? selectedLocation,
    LatLng? currentLocation,
    TextEditingController? addressController,
    TextEditingController? latitudeController,
    TextEditingController? longitudeController,
  }) {
    return CreateAnnouncementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      selectedType: selectedType ?? this.selectedType,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      showMap: showMap ?? this.showMap,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      longitudeController: longitudeController ?? this.longitudeController,
      latitudeController: latitudeController ?? this.latitudeController
    );
  }
}
