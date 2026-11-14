import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/admin_models.dart';
import '../../listing_detail/constants/listing_detail_constants.dart';
import '../../listing_detail/controllers/listing_detail_controller.dart';
import '../../listing_detail/views/listing_detail_view.dart';
import '../constants/admin_constants.dart';

/// What the review screen returns to the activities list.
enum ActivityDecision { accept, reject }

/// Admin — an activity submission shown as its product page, so the admin
/// sees what travellers will see, with Reject / Accept at the foot.
///
/// Route arguments: the [AdminActivitySubmission]. Pops with an
/// [ActivityDecision]; the activities list makes the API call.
class AdminActivityReviewView extends GetView<ListingDetailController> {
  const AdminActivityReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final submission = args is AdminActivitySubmission ? args : null;
    final canDecide = submission?.isPending ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: ListingDetailPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ListingDetailPalette.white,
        extendBodyBehindAppBar: true,
        body: Obx(() {
          final detail = controller.detail.value;
          if (detail == null) {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AdminSizes.pagePadding),
                      child: Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: ListingDetailStyle.aboutBody,
                      ),
                    ),
                  );
          }
          return ListingDetailBody(
            detail: detail,
            controller: controller,
            forReview: true,
          );
        }),
        bottomNavigationBar: canDecide ? const _DecisionBar() : null,
      ),
    );
  }
}

class _DecisionBar extends StatelessWidget {
  const _DecisionBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AdminPalette.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AdminSizes.pagePadding,
            12,
            AdminSizes.pagePadding,
            12,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(result: ActivityDecision.reject),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    AdminStrings.reject,
                    style: TextStyle(
                      color: AdminPalette.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AdminGradients.prime,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () => Get.back(result: ActivityDecision.accept),
                      child: const SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(AdminStrings.accept, style: AdminStyle.cta),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
