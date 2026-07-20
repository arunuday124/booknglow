import 'package:get/get.dart';

class BookingsController extends GetxController {
  // 0 for Upcoming, 1 for History
  final RxInt selectedTab = 0.obs;

  void selectTab(int index) {
    selectedTab.value = index;
  }
}
