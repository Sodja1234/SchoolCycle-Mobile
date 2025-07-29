import 'package:odc_mobile_template/business/models/geolocation/geolocation.dart';

abstract class GeolocationService {
  Future<Geolocation> getCurrentLocation();
  Future<String> getAddressFromCoordinates(double lat, double lng);
  Future<Geolocation> searchAddress(String query);
}