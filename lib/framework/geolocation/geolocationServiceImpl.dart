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

  @override
  Future<Geolocation> getCurrentLocation() async{
    try {
      // Vérification des services de localisation
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Les services de localisation sont désactivés');
      }

      // Vérification des permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de localisation refusée');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée définitivement');
      }

      // Récupération de la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Conversion en adresse
      final address = await getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );

      return Geolocation(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Erreur getCurrentLocation: $e');
      rethrow;
    }
  }


  @override
  Future<Geolocation> searchAddress(String query) async{
    if (query.trim().isEmpty) {
      throw Exception('La requête de recherche est vide');
    }

    try {
      final url = 'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isEmpty) {
          throw Exception('Aucun résultat trouvé pour cette adresse');
        }

        final result = results[0];
        final lat = double.parse(result['lat']);
        final lon = double.parse(result['lon']);
        
        // Récupération de l'adresse complète
        final address = await getAddressFromCoordinates(lat, lon);

        return Geolocation(
          address: address,
          latitude: lat,
          longitude: lon,
        );
      } else {
        throw Exception('Erreur de recherche d\'adresse: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur searchAddress: $e');
      rethrow;
    }
  }
}