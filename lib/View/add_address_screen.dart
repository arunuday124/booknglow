import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/saved_address_model.dart';
import '../service/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  /// The locationName and full address string from the location picker.
  final String locationName;
  final String locationAddress;
  final GeoPoint location;

  const AddAddressScreen({
    super.key,
    required this.locationName,
    required this.locationAddress,
    required this.location,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _houseController = TextEditingController();
  final _floorController = TextEditingController();
  final _buildingController = TextEditingController();
  final _landmarkController = TextEditingController();

  String _selectedType = 'Home';
  bool _isSaving = false;

  static const _green = Color(0xFF05352F);
  static const _bg = Color(0xFFFAF9F5);
  static const _textMuted = Color(0xFF7A8D87);

  final List<Map<String, dynamic>> _types = [
    {'label': 'Home', 'icon': Icons.home_outlined},
    {'label': 'Work', 'icon': Icons.work_outline},
    {'label': 'Other', 'icon': Icons.location_on_outlined},
  ];

  @override
  void dispose() {
    _houseController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  String _buildFullAddress() {
    final parts = <String>[];
    if (_houseController.text.trim().isNotEmpty)
      parts.add(_houseController.text.trim());
    if (_floorController.text.trim().isNotEmpty)
      parts.add('Floor ${_floorController.text.trim()}');
    if (_buildingController.text.trim().isNotEmpty)
      parts.add(_buildingController.text.trim());
    if (_landmarkController.text.trim().isNotEmpty)
      parts.add(_landmarkController.text.trim());
    parts.add(widget.locationAddress);
    return parts.join(', ');
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = Timestamp.now();
      final model = SavedAddressModel(
        address: _buildFullAddress(),
        building: _buildingController.text.trim(),
        createdAt: now,
        floor: _floorController.text.trim(),
        houseNo: _houseController.text.trim(),
        isFavorite: false,
        isSelected: true,
        landmark: _landmarkController.text.trim(),
        location: widget.location,
        locationName: widget.locationName,
        name: _selectedType,
        type: _selectedType,
        updatedAt: now,
      );

      await AddressService.addAddress(model);

      // Pop back to Select Location screen first
      Get.back(result: true);

      // Show top success snackbar on Select Location screen
      Get.snackbar(
        'Address Saved',
        'Your address has been saved successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: _green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _green),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Your Address',
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _green,
            ),
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 8,
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'SAVE ADDRESS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location preview card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.locationName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _green,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.locationAddress,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section label
              Text(
                'COMPLETE ADDRESS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),

              // House No
              _buildLabel('House / Flat / Block No.', required: true),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _houseController,
                hint: 'Enter house number',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Floor
              _buildLabel('Floor (Optional)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _floorController,
                hint: 'Enter floor number',
              ),
              const SizedBox(height: 16),

              // Building
              _buildLabel('Apartment / Road / Area', required: true),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _buildingController,
                hint: 'Enter building or area name',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Landmark
              _buildLabel('Nearby Landmark (Optional)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _landmarkController,
                hint: 'E.g., Near Metro Station',
              ),
              const SizedBox(height: 28),

              // Save As
              Text(
                'SAVE AS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _types.map((t) {
                  final isSelected = _selectedType == t['label'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = t['label']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? _green
                                : const Color(0xFFDDE3E0),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _green.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              t['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.white : _textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t['label'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3E3A),
        ),
        children: required
            ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: const Color(0xFF2C3E3A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDE3E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDE3E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
