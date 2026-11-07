import 'package:get/get.dart';

import '../controllers/partner_notifications_controller.dart';

class PartnerNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerNotificationsController>(
      () => PartnerNotificationsController(),
    );
  }
}
