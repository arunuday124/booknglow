import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../service/user_service.dart';

class PersonalInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  final RxBool isLoading = false.obs;
  final RxString nameInitials = '?'.obs;
  final RxnString selectedImagePath = RxnString();
  final RxnString currentPhotoUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    nameController.addListener(() {
      _updateInitials(nameController.text);
    });

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    emailController.text = user?.email ?? '';

    // Fetches user profile (cached after first launch, 0 DB calls when changing pages)
    final userModel = await UserService.getCurrentUser();

    if (userModel != null) {
      if (userModel.name.isNotEmpty) {
        nameController.text = userModel.name;
      } else if (user?.displayName != null && user!.displayName!.isNotEmpty) {
        nameController.text = user.displayName!;
      }

      if (userModel.phone != 0) {
        phoneController.text = userModel.phone.toString();
      } else if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) {
        phoneController.text = user.phoneNumber!;
      }

      if (userModel.profileImages.isNotEmpty) {
        currentPhotoUrl.value = userModel.profileImages;
      } else if (user?.photoURL != null) {
        currentPhotoUrl.value = user!.photoURL;
      }
    } else if (user != null) {
      nameController.text = user.displayName ?? '';
      phoneController.text = user.phoneNumber ?? '';
      currentPhotoUrl.value = user.photoURL;
    }

    _updateInitials(nameController.text);
  }

  void _updateInitials(String name) {
    if (name.trim().isEmpty) {
      nameInitials.value = '?';
      return;
    }
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      nameInitials.value = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return;
    }
    final n = parts[0];
    nameInitials.value = n.length > 1
        ? '${n[0]}${n[1]}'.toUpperCase()
        : n[0].toUpperCase();
  }

  Future<void> pickAndCropImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: const Color(0xFF05352F),
            toolbarWidgetColor: const Color(0xFFE8D5AF),
            activeControlsWidgetColor: const Color(0xFF9E7E45),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile != null) {
        selectedImagePath.value = croppedFile.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick or crop image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  void removePhoto() {
    selectedImagePath.value = null;
    currentPhotoUrl.value = null;
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      final newName = nameController.text.trim();
      final phoneDigits = phoneController.text.replaceAll(RegExp(r'\D'), '');
      final newPhoneInt = int.tryParse(phoneDigits) ?? 0;

      String? photoToSave = currentPhotoUrl.value;
      if (selectedImagePath.value != null) {
        photoToSave = selectedImagePath.value;
        currentPhotoUrl.value = photoToSave;
      }

      // Update FirebaseAuth user display name & photo URL
      await user.updateDisplayName(newName);
      if (photoToSave != null) {
        await user.updatePhotoURL(photoToSave);
      }

      // Update Firestore DB document & memory cache
      final fieldsToUpdate = <String, dynamic>{
        'name': newName,
        'phone': newPhoneInt,
      };
      if (photoToSave != null) {
        fieldsToUpdate['profileImages'] = photoToSave;
      }

      await UserService.updateUserFields(user.uid, fieldsToUpdate);

      _updateInitials(newName);
      isLoading.value = false;

      Get.snackbar(
        'Profile Updated',
        'Your profile has been saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        'Update Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
