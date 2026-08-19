import 'package:get/get.dart';
import '../model/saved_address_model.dart';
import '../service/address_service.dart';

class AddressController extends GetxController {
  /// All saved addresses from Firestore.
  final RxList<SavedAddressModel> addresses = <SavedAddressModel>[].obs;

  /// The currently selected address (null if none).
  final Rxn<SavedAddressModel> selectedAddress = Rxn<SavedAddressModel>();

  /// Search query state for saved addresses.
  final RxString searchQuery = ''.obs;

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  /// Filtered list of saved addresses matching searchQuery.
  List<SavedAddressModel> get filteredAddresses {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return addresses;
    }
    return addresses.where((addr) {
      return addr.name.toLowerCase().contains(query) ||
          addr.address.toLowerCase().contains(query) ||
          addr.locationName.toLowerCase().contains(query) ||
          addr.building.toLowerCase().contains(query) ||
          addr.landmark.toLowerCase().contains(query) ||
          addr.type.toLowerCase().contains(query) ||
          addr.houseNo.toLowerCase().contains(query);
    }).toList();
  }

  /// Loading state for operations.
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Keep selected address in sync when addresses list changes.
    ever(addresses, (_) {
      selectedAddress.value = addresses.firstWhereOrNull((a) => a.isSelected);
    });

    fetchAddresses();
  }

  /// Fetches saved addresses from Firestore once.
  Future<void> fetchAddresses() async {
    isLoading.value = true;
    try {
      final list = await AddressService.fetchAddresses();
      addresses.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Select an address by its Firestore document ID.
  /// Optimistically updates local memory state instantly for 0ms UI feedback.
  Future<void> selectAddress(String docId) async {
    // 1. Optimistic Local Update: Mark selected address immediately in memory
    final updatedList = addresses.map((addr) {
      return addr.copyWith(isSelected: addr.id == docId);
    }).toList();
    addresses.assignAll(updatedList);
    selectedAddress.value = addresses.firstWhereOrNull((a) => a.isSelected);

    // 2. Perform Firestore update in the background
    try {
      await AddressService.selectAddress(docId);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      // Revert from server if network failed
      await fetchAddresses();
    }
  }

  /// Toggle favorite on an address with instant local UI update.
  Future<void> toggleFavorite(String docId, bool current) async {
    final updatedList = addresses.map((addr) {
      if (addr.id == docId) {
        return addr.copyWith(isFavorite: !current);
      }
      return addr;
    }).toList();
    addresses.assignAll(updatedList);

    try {
      await AddressService.toggleFavorite(docId, current);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      await fetchAddresses();
    }
  }

  /// Delete an address with instant local removal.
  Future<void> deleteAddress(String docId) async {
    addresses.removeWhere((addr) => addr.id == docId);

    try {
      await AddressService.deleteAddress(docId);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      await fetchAddresses();
    }
  }
}
