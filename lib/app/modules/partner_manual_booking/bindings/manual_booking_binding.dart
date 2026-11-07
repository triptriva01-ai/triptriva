import 'package:get/get.dart';

import '../controllers/manual_booking_controller.dart';

class ManualBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualBookingController>(() => ManualBookingController());
  }
}
