import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<String> getUserLocation() async {
    try {
      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Open app settings if denied
          await openAppSettings();
          return "Location permission denied";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Open app settings for permanently denied permissions
        await openAppSettings();
        return "Location permission permanently denied";
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
    } catch (e) {
      return "Error fetching location: $e";
    }
  }
}
