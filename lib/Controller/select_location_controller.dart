import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/location_service.dart';
import '../View/add_address_screen.dart';

class SelectLocationController extends GetxController {
  final RxBool isFetchingLocation = false.obs;

  Future<void> handleGetCurrentLocation() async {
    isFetchingLocation.value = true;
    try {
      final result = await LocationService.getCurrentLocation();

      Get.to(
        () => AddAddressScreen(
          locationName: result.locationName,
          locationAddress: result.locationAddress,
          location: GeoPoint(result.latitude, result.longitude),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Location Access',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } finally {
      isFetchingLocation.value = false;
    }
  }
}
