import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Location services disabled";
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permission denied";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Location permissions are permanently denied";
    }

    // Get position
    Position position = await Geolocator.getCurrentPosition();
    return "${position.latitude}, ${position.longitude}";
  }
}
