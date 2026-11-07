import 'package:get/get.dart';

import '../controllers/edit_allocation_controller.dart';

class EditAllocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditAllocationController>(() => EditAllocationController());
  }
}
