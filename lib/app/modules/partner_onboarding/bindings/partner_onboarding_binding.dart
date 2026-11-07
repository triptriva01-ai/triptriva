import 'package:get/get.dart';

import '../controllers/partner_onboarding_controller.dart';

class PartnerOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerOnboardingController>(
      () => PartnerOnboardingController(),
    );
  }
}
