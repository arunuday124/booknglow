import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class PersonalInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  final RxBool isLoading = false.obs;
  final RxString nameInitials = '?'.obs;
  final RxnString selectedImagePath = RxnString();
  final RxnString currentPhotoUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    nameController = TextEditingController(text: user?.displayName ?? '');
    phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    addressController = TextEditingController();
    currentPhotoUrl.value = user?.photoURL;

    // Listen to name changes to update initials reactively
    _updateInitials(nameController.text);
    nameController.addListener(() {
      _updateInitials(nameController.text);
    });
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
            aspectRatioPresets: const [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: const [
              CropAspectRatioPreset.square,
            ],
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
      
      // Update display name
      await user?.updateDisplayName(nameController.text.trim());

      // If we have a local cropped file path, simulate or save the photo URL.
      // Firebase Auth allows storing a string URL. We can store the local file URI/path,
      // or print that in production it would be uploaded to storage.
      if (selectedImagePath.value != null) {
        await user?.updatePhotoURL(selectedImagePath.value);
        currentPhotoUrl.value = selectedImagePath.value;
      } else if (currentPhotoUrl.value == null) {
        await user?.updatePhotoURL(null);
      }

      isLoading.value = false;

      Get.snackbar(
        'Profile Updated',
        'Your personal information has been saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );

      Get.back();
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
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
