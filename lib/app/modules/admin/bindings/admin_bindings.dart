import 'package:get/get.dart';

import '../controllers/admin_controller.dart';
import '../controllers/admin_profile_controller.dart';

class AdminRevenueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminRevenueController>(AdminRevenueController.new);
  }
}

class AdminActivitiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminActivitiesController>(AdminActivitiesController.new);
  }
}

class AdminPaymentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminPaymentsController>(AdminPaymentsController.new);
  }
}

class AdminUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUsersController>(AdminUsersController.new);
  }
}

class AdminProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminProfileController>(AdminProfileController.new);
  }
}
