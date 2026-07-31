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
    // Listen to Firestore stream and keep local state in sync.
    ever(addresses, (_) {
      selectedAddress.value = addresses.firstWhereOrNull((a) => a.isSelected);
    });

    AddressService.streamAddresses().listen((list) {
      addresses.assignAll(list);
    });
  }

  /// Select an address by its Firestore document ID.
  Future<void> selectAddress(String docId) async {
    isLoading.value = true;
    try {
      await AddressService.selectAddress(docId);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle favorite on an address.
  Future<void> toggleFavorite(String docId, bool current) async {
    try {
      await AddressService.toggleFavorite(docId, current);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// Delete an address.
  Future<void> deleteAddress(String docId) async {
    try {
      await AddressService.deleteAddress(docId);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
