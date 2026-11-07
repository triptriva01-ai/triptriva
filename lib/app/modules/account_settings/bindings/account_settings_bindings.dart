import 'package:get/get.dart';

import '../controllers/account_settings_controllers.dart';

class FeedbackBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<FeedbackController>(FeedbackController.new);
}

class LanguageBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<LanguageController>(LanguageController.new);
}

class CustomerSupportBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<CustomerSupportController>(CustomerSupportController.new);
}

class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<PaymentMethodsController>(PaymentMethodsController.new);
}
