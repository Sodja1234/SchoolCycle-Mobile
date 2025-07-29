import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:odc_mobile_template/business/models/geolocation/geolocation.dart';
import 'package:odc_mobile_template/business/services/geolocation/geolocationService.dart';

class GeolocationServiceImpl implements GeolocationService {

  @override
  Future<String> getAddressFromCoordinates(double lat, double lng) async{
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return 'Adresse inconnue';
      }

      Placemark place = placemarks[0];
      String address = '';
      
      // Construction de l'adresse
      if (place.street != null && place.street!.isNotEmpty) {
        address += place.street!;
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += place.locality!;
      }
      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        if (address.isNotEmpty) address += ' ';
        address += place.postalCode!;
      }
      if (place.country != null && place.country!.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += place.country!;
      }

      return address;
    } catch (e) {
      print('Erreur getAddressFromCoordinates: $e');
      return 'Adresse non disponible';
    }
  }

  
}