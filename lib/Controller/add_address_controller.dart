import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/saved_address_model.dart';
import '../service/address_service.dart';
import '../service/location_service.dart';

class AddAddressController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final houseController = TextEditingController();
  final floorController = TextEditingController();
  final buildingController = TextEditingController();
  final landmarkController = TextEditingController();

  final RxString selectedType = 'Home'.obs;
  final RxBool isSaving = false.obs;

  String? editingAddressId;
  SavedAddressModel? existingAddressModel;

  static const Color greenColor = Color(0xFF05352F);

  @override
  void onClose() {
    houseController.dispose();
    floorController.dispose();
    buildingController.dispose();
    landmarkController.dispose();
    super.onClose();
  }

  final RxBool isFetchingLocation = false.obs;

  void initForAddress(SavedAddressModel? model) {
    if (model != null) {
      editingAddressId = model.id;
      existingAddressModel = model;
      houseController.text = model.houseNo;
      floorController.text = model.floor;
      buildingController.text = model.building;
      landmarkController.text = model.landmark;
      selectedType.value = model.type;
    } else {
      editingAddressId = null;
      existingAddressModel = null;
      houseController.clear();
      floorController.clear();
      buildingController.clear();
      landmarkController.clear();
      selectedType.value = 'Home';
    }
  }

  void initForLocation({
    required String locationName,
    required String locationAddress,
    required GeoPoint location,
    String? houseNo,
    String? floor,
    String? building,
    String? landmark,
  }) {
    editingAddressId = null;
    existingAddressModel = null;

    houseController.text = (houseNo != null && houseNo.isNotEmpty)
        ? houseNo
        : (locationName.isNotEmpty &&
                locationName != 'Current Location' &&
                locationName != 'My Location'
            ? locationName
            : '');

    floorController.text = floor ?? '';

    buildingController.text = (building != null && building.isNotEmpty)
        ? building
        : (locationAddress.isNotEmpty &&
                locationAddress != 'Enter your full address'
            ? locationAddress
            : '');

    landmarkController.text = landmark ?? '';
    selectedType.value = 'Home';
  }

  Future<void> fetchAndFillCurrentLocation() async {
    isFetchingLocation.value = true;
    try {
      final result = await LocationService.getCurrentLocation();
      initForLocation(
        locationName: result.locationName,
        locationAddress: result.locationAddress,
        location: GeoPoint(result.latitude, result.longitude),
        houseNo: result.houseNo,
        floor: result.floor,
        building: result.building,
        landmark: result.landmark,
      );

      Get.snackbar(
        'Location Detected',
        'Address fields filled from your current location.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: greenColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Location Error',
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

  void selectType(String type) {
    selectedType.value = type;
  }

  String buildFullAddress(String baseLocationAddress) {
    final parts = <String>[];
    if (houseController.text.trim().isNotEmpty) {
      parts.add(houseController.text.trim());
    }
    if (floorController.text.trim().isNotEmpty) {
      parts.add('Floor ${floorController.text.trim()}');
    }
    if (buildingController.text.trim().isNotEmpty) {
      parts.add(buildingController.text.trim());
    }
    if (landmarkController.text.trim().isNotEmpty) {
      parts.add(landmarkController.text.trim());
    }
    parts.add(baseLocationAddress);
    return parts.join(', ');
  }

  Future<void> saveAddress({
    required String locationName,
    required String locationAddress,
    required GeoPoint location,
  }) async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;

    try {
      final now = Timestamp.now();

      if (editingAddressId != null && editingAddressId!.isNotEmpty) {
        // Edit existing address
        final updatedModel = SavedAddressModel(
          id: editingAddressId,
          address: buildFullAddress(locationAddress),
          building: buildingController.text.trim(),
          createdAt: existingAddressModel?.createdAt ?? now,
          floor: floorController.text.trim(),
          houseNo: houseController.text.trim(),
          isFavorite: existingAddressModel?.isFavorite ?? false,
          isSelected: existingAddressModel?.isSelected ?? true,
          landmark: landmarkController.text.trim(),
          location: location,
          locationName: locationName,
          name: selectedType.value,
          type: selectedType.value,
          updatedAt: now,
        );

        await AddressService.updateAddress(editingAddressId!, updatedModel);

        Get.back(result: true);

        Get.snackbar(
          'Address Updated',
          'Your address has been updated successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: greenColor,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      } else {
        // Create new address
        final model = SavedAddressModel(
          address: buildFullAddress(locationAddress),
          building: buildingController.text.trim(),
          createdAt: now,
          floor: floorController.text.trim(),
          houseNo: houseController.text.trim(),
          isFavorite: false,
          isSelected: true,
          landmark: landmarkController.text.trim(),
          location: location,
          locationName: locationName,
          name: selectedType.value,
          type: selectedType.value,
          updatedAt: now,
        );

        await AddressService.addAddress(model);

        Get.back(result: true);

        Get.snackbar(
          'Address Saved',
          'Your address has been saved successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: greenColor,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }

      // Reset form fields
      editingAddressId = null;
      existingAddressModel = null;
      houseController.clear();
      floorController.clear();
      buildingController.clear();
      landmarkController.clear();
      selectedType.value = 'Home';
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSaving.value = false;
    }
  }
}
