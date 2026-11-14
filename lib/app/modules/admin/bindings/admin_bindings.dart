import 'package:get/get.dart';

import '../controllers/admin_controller.dart';
import '../../listing_detail/controllers/listing_detail_controller.dart';
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

/// Reuses the product page's controller; the submission's id is the
/// listing's id.
class AdminActivityReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingDetailController>(ListingDetailController.new);
  }
}

class AdminProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminProfileController>(AdminProfileController.new);
  }
}
