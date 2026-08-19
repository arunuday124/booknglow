import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/address_controller.dart';
import '../Controller/select_location_controller.dart';
import '../model/saved_address_model.dart';
import 'add_address_screen.dart';

class SelectLocationScreen extends StatelessWidget {
  const SelectLocationScreen({super.key});

  static const _green = Color(0xFF05352F);
  static const _bg = Color(0xFFFAF9F5);
  static const _textMuted = Color(0xFF7A8D87);

  @override
  Widget build(BuildContext context) {
    final addressController = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());
    final locationController = Get.put(SelectLocationController());

    final searchController = TextEditingController(
      text: addressController.searchQuery.value,
    );

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
          'Select Your Location',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE3E0)),
              ),
              child: Obx(
                () => TextField(
                  controller: searchController,
                  onChanged: addressController.updateSearchQuery,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF2C3E3A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search saved address, area or landmark',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: _textMuted,
                      size: 20,
                    ),
                    suffixIcon: addressController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: _textMuted,
                              size: 18,
                            ),
                            onPressed: () {
                              addressController.clearSearch();
                              searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Quick Action Buttons ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Obx(
                  () => _ActionButton(
                    icon: Icons.my_location,
                    label: 'Use Current\nLocation',
                    isLoading: locationController.isFetchingLocation.value,
                    onTap: locationController.isFetchingLocation.value
                        ? () {}
                        : () => locationController.handleGetCurrentLocation(),
                  ),
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Add New\nAddress',
                  onTap: () {
                    // Navigate to add address with a placeholder location
                    Get.to(
                      () => const AddAddressScreen(
                        locationName: 'My Location',
                        locationAddress: 'Enter your full address',
                        location: GeoPoint(0, 0),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Request\nAddress',
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Request address feature is coming soon.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: _green,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Saved Addresses Label ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              final isSearching = addressController.searchQuery.value
                  .trim()
                  .isNotEmpty;
              final count = addressController.filteredAddresses.length;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSearching ? 'SEARCH RESULTS' : 'SAVED ADDRESSES',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (isSearching)
                    Text(
                      '$count found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _green,
                      ),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),

          // ── Address List ────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: _green,
              onRefresh: addressController.fetchAddresses,
              child: Obx(() {
                final isSearching = addressController.searchQuery.value
                    .trim()
                    .isNotEmpty;
                final addresses = addressController.filteredAddresses;

                if (addresses.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSearching
                                  ? Icons.search_off_rounded
                                  : Icons.location_off_outlined,
                              size: 48,
                              color: _textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isSearching
                                  ? 'No matching addresses found'
                                  : 'No saved addresses yet',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: _textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isSearching
                                  ? 'Try searching with a different area or keyword'
                                  : 'Tap "Add New Address" to get started',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: _textMuted.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return _AddressCard(
                      address: addr,
                      onSelect: () => addressController.selectAddress(addr.id!),
                      onToggleFavorite: () => addressController.toggleFavorite(
                        addr.id!,
                        addr.isFavorite,
                      ),
                      onDelete: () => addressController.deleteAddress(addr.id!),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Button ──────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isLoading = false,
    required this.onTap,
  });

  static const _green = Color(0xFF05352F);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE3E0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _green,
                  ),
                )
              else
                Icon(icon, color: _green, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _green,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Address Card ─────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final SavedAddressModel address;
  final VoidCallback onSelect;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  static const _green = Color(0xFF05352F);
  static const _textMuted = Color(0xFF7A8D87);

  IconData _typeIcon() {
    switch (address.type) {
      case 'Work':
        return Icons.work_outline;
      case 'Home':
        return Icons.home_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: address.isSelected ? _green : const Color(0xFFDDE3E0),
            width: address.isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: address.isSelected
                  ? _green.withOpacity(0.08)
                  : const Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon + distance
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: address.isSelected
                        ? _green.withOpacity(0.08)
                        : const Color(0xFFF0F4F3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_typeIcon(), color: _green, size: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  '~',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _green,
                        ),
                      ),
                      if (address.isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'SELECTED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _green,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Favorite + menu
            Column(
              children: [
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: Icon(
                    address.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: address.isFavorite ? Colors.redAccent : _textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showMenu(context),
                  child: const Icon(
                    Icons.more_vert,
                    color: _textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: _green),
              title: Text(
                'Edit Address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _green,
                ),
              ),
              onTap: () {
                Get.back();
                Get.to(
                  () => AddAddressScreen(
                    locationName: address.locationName.isNotEmpty
                        ? address.locationName
                        : 'My Location',
                    locationAddress: address.address,
                    location: address.location,
                    existingAddress: address,
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                'Delete Address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                ),
              ),
              onTap: () {
                Get.back();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
