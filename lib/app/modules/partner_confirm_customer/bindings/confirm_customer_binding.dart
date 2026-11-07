import 'package:get/get.dart';

import '../controllers/confirm_customer_controller.dart';

class ConfirmCustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmCustomerController>(() => ConfirmCustomerController());
  }
}
