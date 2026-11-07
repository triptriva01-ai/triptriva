import 'package:get/get.dart';

import '../controllers/partner_dashboard_controller.dart';

class PartnerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerDashboardController>(
      () => PartnerDashboardController(),
    );
  }
}
