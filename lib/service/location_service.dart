import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String locationName;
  final String locationAddress;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.locationAddress,
  });
}

class LocationService {
  /// Fetches the current GPS position and reverse geocodes it to a location name and address.
  static Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, ask user to enable it.
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please turn on GPS.');
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // Reverse geocode to get address details
    String locationName = 'Current Location';
    String locationAddress =
        '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build location name (e.g. SubLocality, Locality)
        final nameParts = <String>[];
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          nameParts.add(place.subLocality!);
        } else if (place.name != null && place.name!.isNotEmpty) {
          nameParts.add(place.name!);
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          nameParts.add(place.locality!);
        }

        if (nameParts.isNotEmpty) {
          locationName = nameParts.join(', ');
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          locationName = place.administrativeArea!;
        }

        // Build full address
        final addrParts = <String>[];
        if (place.street != null &&
            place.street!.isNotEmpty &&
            place.street != place.name) {
          addrParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addrParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addrParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addrParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addrParts.add(place.postalCode!);
        }

        if (addrParts.isNotEmpty) {
          locationAddress = addrParts.join(', ');
        }
      }
    } catch (e) {
      // Fallback if reverse geocoding fails or is unavailable
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: locationName,
      locationAddress: locationAddress,
    );
  }
}
