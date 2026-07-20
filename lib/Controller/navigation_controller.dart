import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Active tab index
  final RxInt selectedIndex = 0.obs;

  // Change active tab
  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
