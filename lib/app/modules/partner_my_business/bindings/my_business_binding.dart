import 'package:get/get.dart';

import '../controllers/my_business_controller.dart';

class MyBusinessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBusinessController>(() => MyBusinessController());
  }
}
