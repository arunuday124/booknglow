import 'package:get/get.dart';
import '../model/saved_address_model.dart';
import '../service/address_service.dart';

class AddressController extends GetxController {
  /// All saved addresses from Firestore.
  final RxList<SavedAddressModel> addresses = <SavedAddressModel>[].obs;

  /// The currently selected address (null if none).
  final Rxn<SavedAddressModel> selectedAddress = Rxn<SavedAddressModel>();

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
