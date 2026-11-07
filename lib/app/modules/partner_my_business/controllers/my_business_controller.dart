import 'package:get/get.dart';

import '../../../data/models/partner_activity.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/partner/partner_bottom_nav.dart';

/// Partner-side Page 05 — My Business.
///
/// Lists everything the partner has published, live or not, and is the entry
/// point to the "Add Activity" onboarding wizard.
class MyBusinessController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();

  final partnerName = 'Partner'.obs;
  final activities = <PartnerActivity>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentTab = PartnerBottomNav.myBusiness.obs;

  /// Index into [filters]; 0 is "All".
  final selectedFilter = 0.obs;

  /// "Active" = accepted and live; "De active" = in review or rejected.
  static const filters = ['All', 'Active', 'De active'];

  bool get hasActivities => activities.isNotEmpty;

  List<PartnerActivity> get visibleActivities {
    return switch (selectedFilter.value) {
      1 => activities.where((activity) => activity.isActive).toList(),
      2 => activities.where((activity) => !activity.isActive).toList(),
      _ => activities.toList(),
    };
  }

  @override
  void onInit() {
    super.onInit();
    _partnerService.displayName().then((name) {
      if (name != null) partnerName.value = name;
    });
    loadActivities();
  }

  Future<void> loadActivities() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      activities.assignAll(await _partnerService.getMyListings());
    } on ApiException catch (error) {
      Get.log('Partner activities load failed: $error');
      errorMessage.value = error.message;
      activities.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectFilter(int index) => selectedFilter.value = index;

  /// FR — "Add Activity" starts the listing wizard; the list reloads after.
  Future<void> addActivity() async {
    await Get.toNamed(Routes.PARTNER_ONBOARDING);
    await loadActivities();
  }

  void openActivity(PartnerActivity activity) {
    final message = switch (activity.status) {
      'pending' => 'In review — an admin will approve it before guests can book.',
      'rejected' =>
        'Rejected: ${activity.rejectionReason ?? 'no reason given'}. Edit and resubmit it.',
      _ => 'Live — guests can book it now.',
    };
    Get.snackbar(activity.name, message, snackPosition: SnackPosition.BOTTOM);
  }

  void openNotifications() => Get.toNamed(Routes.PARTNER_NOTIFICATIONS);

  void openProfile() => Get.toNamed(Routes.PARTNER_PROFILE);

  void onTabSelected(int index) {
    if (index == currentTab.value) {
      return;
    }
    switch (index) {
      case PartnerBottomNav.reservations:
        Get.offNamed(Routes.PARTNER_DASHBOARD);
      case PartnerBottomNav.quickUpdates:
        Get.offNamed(Routes.PARTNER_QUICK_UPDATES);
      case PartnerBottomNav.revenue:
        Get.offNamed(Routes.PARTNER_REVENUE);
    }
  }
}
