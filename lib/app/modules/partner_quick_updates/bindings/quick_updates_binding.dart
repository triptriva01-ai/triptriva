import 'package:get/get.dart';

import '../controllers/quick_updates_controller.dart';

class QuickUpdatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuickUpdatesController>(
      () => QuickUpdatesController(),
    );
  }
}
