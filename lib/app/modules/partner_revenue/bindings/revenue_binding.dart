import 'package:get/get.dart';

import '../controllers/revenue_controller.dart';

class RevenueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RevenueController>(() => RevenueController());
  }
}
