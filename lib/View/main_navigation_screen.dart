import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/address_controller.dart';
import '../Controller/navigation_controller.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject or retrieve NavigationController
    final controller = Get.put(NavigationController());
    // Register AddressController globally so HomeScreen's AppBar can find it
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController());
    }

    // Screens list corresponding to indices
    final List<Widget> screens = const [
      HomeScreen(),
      BookingsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, // Allow body content to extend below bottom navigation bar
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF05352F).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                controller: controller,
                index: 0,
                outlineIcon: Icons.home_outlined,
                solidIcon: Icons.home_rounded,
                label: "Home",
              ),
              _buildNavItem(
                controller: controller,
                index: 1,
                outlineIcon: Icons.calendar_today_outlined,
                solidIcon: Icons.calendar_today_rounded,
                label: "Bookings",
              ),
              _buildNavItem(
                controller: controller,
                index: 2,
                outlineIcon: Icons.person_outline_rounded,
                solidIcon: Icons.person_rounded,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavigationController controller,
    required int index,
    required IconData outlineIcon,
    required IconData solidIcon,
    required String label,
  }) {
    final isSelected = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF6EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? solidIcon : outlineIcon,
              color: isSelected ? const Color(0xFF9E7E45) : const Color(0xFF7A8D87),
              size: 22,
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E7E45),
                    ),
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
