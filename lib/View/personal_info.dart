import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../Controller/personal_info_controller.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  // Brand colours
  static const _deepGreen = Color(0xFF05352F);
  static const _gold = Color(0xFF9E7E45);
  static const _cream = Color(0xFFFAF9F5);
  static const _mutedTeal = Color(0xFF7A8D87);
  static const _cardBg = Colors.white;

  void _showImagePickerSourceSheet(BuildContext context, PersonalInfoController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Change Profile Photo",
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _deepGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: _deepGreen),
                  title: Text("Take Photo", style: GoogleFonts.plusJakartaSans()),
                  onTap: () {
                    Get.back();
                    controller.pickAndCropImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: _deepGreen),
                  title: Text("Choose from Gallery", style: GoogleFonts.plusJakartaSans()),
                  onTap: () {
                    Get.back();
                    controller.pickAndCropImage(ImageSource.gallery);
                  },
                ),
                Obx(() {
                  if (controller.selectedImagePath.value != null || controller.currentPhotoUrl.value != null) {
                    return ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                      title: Text(
                        "Remove Current Photo",
                        style: GoogleFonts.plusJakartaSans(color: Colors.red),
                      ),
                      onTap: () {
                        Get.back();
                        controller.removePhoto();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(PersonalInfoController());

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: _deepGreen,
            ),
          ),
        ),
        title: Text(
          "Personal Information",
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _deepGreen,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Avatar section ───────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => _showImagePickerSourceSheet(context, controller),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE8D5AF), _gold],
                          ),
                        ),
                        child: Obx(() {
                          final localPath = controller.selectedImagePath.value;
                          final currentUrl = controller.currentPhotoUrl.value;

                          Widget avatarChild;
                          if (localPath != null) {
                            avatarChild = Image.file(File(localPath), fit: BoxFit.cover);
                          } else if (currentUrl != null && currentUrl.isNotEmpty) {
                            if (currentUrl.startsWith('http')) {
                              avatarChild = Image.network(currentUrl, fit: BoxFit.cover);
                            } else {
                              avatarChild = Image.file(File(currentUrl), fit: BoxFit.cover);
                            }
                          } else {
                            avatarChild = Text(
                              controller.nameInitials.value,
                              style: GoogleFonts.playfairDisplay(
                                textStyle: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE8D5AF),
                                ),
                              ),
                            );
                          }

                          return CircleAvatar(
                            radius: 46,
                            backgroundColor: _cream,
                            child: CircleAvatar(
                              radius: 43,
                              backgroundColor: _deepGreen,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 86,
                                  height: 86,
                                  child: Center(child: avatarChild),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                            border: Border.all(color: _cream, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Tap to change photo",
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: const TextStyle(
                      fontSize: 11,
                      color: _mutedTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),


              // ─── Form card ────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _fieldLabel("FULL NAME"),
                    const SizedBox(height: 6),
                    _buildField(
                      controller: controller.nameController,
                      hint: "e.g. Victoria Sterling",
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Phone Number
                    _fieldLabel("PHONE NUMBER"),
                    const SizedBox(height: 6),
                    _buildField(
                      controller: controller.phoneController,
                      hint: "e.g. +91 98765 43210",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\s\-()]'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Address
                    _fieldLabel("ADDRESS"),
                    const SizedBox(height: 6),
                    _buildField(
                      controller: controller.addressController,
                      hint: "e.g. 42 Rosewood Lane, Mumbai",
                      icon: Icons.location_on_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ─── Update Button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _deepGreen,
                      disabledBackgroundColor: const Color.fromRGBO(5, 53, 47, 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFFE8D5AF),
                              strokeWidth: 2.2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                               Icons.check_rounded,
                               color: Color(0xFFE8D5AF),
                               size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "UPDATE PROFILE",
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE8D5AF),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        textStyle: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4C6B64),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(
        textStyle: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2C3E3A),
        ),
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(icon, size: 18, color: const Color(0xFF4C6B64)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          textStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: maxLines > 1 ? 14 : 8,
        ),
        isDense: true,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _deepGreen, width: 1.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          textStyle: TextStyle(fontSize: 11, color: Colors.red.shade600),
        ),
      ),
    );
  }
}
