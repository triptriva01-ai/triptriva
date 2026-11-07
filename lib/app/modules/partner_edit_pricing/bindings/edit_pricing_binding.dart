import 'package:get/get.dart';

import '../controllers/edit_pricing_controller.dart';

class EditPricingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditPricingController>(() => EditPricingController());
  }
}
