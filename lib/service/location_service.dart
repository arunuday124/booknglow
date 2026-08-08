import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String locationName;
  final String locationAddress;
  final String houseNo;
  final String floor;
  final String building;
  final String landmark;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.locationAddress,
    this.houseNo = '',
    this.floor = '',
    this.building = '',
    this.landmark = '',
  });
}

class LocationService {
  /// Fetches the current GPS position and reverse geocodes it to detailed address components.
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

    // Default fallbacks
    String locationName = 'Current Location';
    String locationAddress =
        '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    String houseNo = '';
    String floor = '';
    String building = '';
    String landmark = '';

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 1. House / Flat / Block No.
        if (place.subThoroughfare != null &&
            place.subThoroughfare!.trim().isNotEmpty) {
          houseNo = place.subThoroughfare!.trim();
        } else if (place.name != null &&
            place.name!.trim().isNotEmpty &&
            place.name != place.street &&
            place.name != place.locality &&
            place.name != place.subLocality) {
          houseNo = place.name!.trim();
        }

        // 2. Floor (if detected in name or street)
        final combined = '${place.name ?? ''} ${place.street ?? ''}'.toLowerCase();
        final floorMatch = RegExp(r'(\d+)(?:st|nd|rd|th)?\s*floor').firstMatch(combined);
        if (floorMatch != null) {
          floor = floorMatch.group(1) ?? '';
        }

        // 3. Apartment / Road / Area
        final buildingParts = <String>{};
        if (place.thoroughfare != null && place.thoroughfare!.trim().isNotEmpty) {
          buildingParts.add(place.thoroughfare!.trim());
        } else if (place.street != null && place.street!.trim().isNotEmpty && place.street != houseNo) {
          buildingParts.add(place.street!.trim());
        }

        if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
          buildingParts.add(place.subLocality!.trim());
        }
        if (place.locality != null && place.locality!.trim().isNotEmpty) {
          buildingParts.add(place.locality!.trim());
        }

        building = buildingParts.join(', ');

        // If houseNo was empty and building is available, use first street part
        if (houseNo.isEmpty && place.name != null && place.name!.trim().isNotEmpty) {
          houseNo = place.name!.trim();
        }

        // 4. Landmark / Nearby Area
        if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
          landmark = 'Near ${place.subLocality!.trim()}';
        } else if (place.administrativeArea != null && place.administrativeArea!.trim().isNotEmpty) {
          landmark = place.administrativeArea!.trim();
        }

        // 5. Short location name
        final nameParts = <String>[];
        if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
          nameParts.add(place.subLocality!.trim());
        } else if (place.locality != null && place.locality!.trim().isNotEmpty) {
          nameParts.add(place.locality!.trim());
        } else if (place.name != null && place.name!.trim().isNotEmpty) {
          nameParts.add(place.name!.trim());
        }

        if (nameParts.isNotEmpty) {
          locationName = nameParts.join(', ');
        } else if (place.administrativeArea != null && place.administrativeArea!.trim().isNotEmpty) {
          locationName = place.administrativeArea!.trim();
        }

        // 6. Full location address string
        final addrParts = <String>[];
        if (houseNo.isNotEmpty) addrParts.add(houseNo);
        if (place.street != null && place.street!.trim().isNotEmpty && place.street != houseNo) {
          addrParts.add(place.street!.trim());
        }
        if (place.subLocality != null && place.subLocality!.trim().isNotEmpty && !addrParts.contains(place.subLocality!.trim())) {
          addrParts.add(place.subLocality!.trim());
        }
        if (place.locality != null && place.locality!.trim().isNotEmpty && !addrParts.contains(place.locality!.trim())) {
          addrParts.add(place.locality!.trim());
        }
        if (place.administrativeArea != null && place.administrativeArea!.trim().isNotEmpty && !addrParts.contains(place.administrativeArea!.trim())) {
          addrParts.add(place.administrativeArea!.trim());
        }
        if (place.postalCode != null && place.postalCode!.trim().isNotEmpty) {
          addrParts.add(place.postalCode!.trim());
        }

        if (addrParts.isNotEmpty) {
          locationAddress = addrParts.join(', ');
        }
      }
    } catch (e) {
      // Fallback if reverse geocoding fails
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: locationName,
      locationAddress: locationAddress,
      houseNo: houseNo,
      floor: floor,
      building: building.isNotEmpty ? building : locationAddress,
      landmark: landmark,
    );
  }
}
