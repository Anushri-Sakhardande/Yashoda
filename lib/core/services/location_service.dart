import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<String> getUserLocation() async {
    try {
      // Get position
      Position position = await Geolocator.getCurrentPosition();

      // Get placemark from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.locality}, ${place.administrativeArea}, ${place.country}";
      }

      return "Location not found";
    } catch (e,stacktrace) {
      //print(e);
      //print("Stacktrace: $stacktrace");
      return "Error fetching location";
    }
  }
}
