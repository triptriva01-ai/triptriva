import 'package:get/get.dart';

import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentController>(PaymentController.new);
  }
}

class BookingSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingSuccessController>(BookingSuccessController.new);
  }
}
