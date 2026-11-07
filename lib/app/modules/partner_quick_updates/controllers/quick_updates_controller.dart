import 'package:get/get.dart';

import '../../../data/models/partner_activity.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/partner/partner_bottom_nav.dart';
import '../constants/quick_updates_constants.dart';

/// Which quick-update section is showing (Sheet2 Page 03, FR-01).
enum QuickUpdateTab { pricesAndDiscount, slotAllocation }

/// Partner-side Page 03 / 3.1 — Quick Updates.
class QuickUpdatesController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();

  final partnerName = QuickUpdatesStrings.placeholderName.obs;
  final selectedTab = QuickUpdateTab.slotAllocation.obs;
  final listings = <PartnerActivity>[].obs;
  final isLoading = false.obs;
  final currentTab = PartnerBottomNav.quickUpdates.obs;

  bool get hasListings => listings.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _partnerService.displayName().then((name) {
      if (name != null) partnerName.value = name;
    });
    loadListings();
  }

  /// Both tabs are driven by the partner's own listings — slot allocation
  /// edits availability, prices & discount edits pricing.
  /// Rejected listings are left out: their calendar and price can't be
  /// edited until the listing is resubmitted.
  Future<void> loadListings() async {
    isLoading.value = true;
    try {
      final rows = await _partnerService.getMyListings();
      listings.assignAll(rows.where((listing) => !listing.isRejected));
    } on ApiException catch (error) {
      Get.log('Partner listings load failed: $error');
      listings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// FR-01 — switch between prices & discount and slot allocation. Both tabs
  /// show the same listings, so there's nothing to reload.
  void selectTab(QuickUpdateTab tab) => selectedTab.value = tab;

  void selectTabAt(int index) => selectTab(QuickUpdateTab.values[index]);

  void openNotifications() => Get.toNamed(Routes.PARTNER_NOTIFICATIONS);

  /// Tapping the avatar/name opens the partner profile.
  void openProfile() => Get.toNamed(Routes.PARTNER_PROFILE);

  /// Page 3.2 — open or close individual dates for one listing.
  Future<void> editAllocation(PartnerActivity listing) async {
    await Get.toNamed(
      Routes.PARTNER_EDIT_ALLOCATION,
      arguments: {'listingId': listing.id, 'listingName': listing.name},
    );
    await loadListings();
  }

  /// Page 3.3 — adjust the discount on one listing.
  Future<void> editPricing(PartnerActivity listing) async {
    await Get.toNamed(
      Routes.PARTNER_EDIT_PRICING,
      arguments: {
        'listingId': listing.id,
        'listingName': listing.name,
        'basePrice': listing.basePrice,
        'discountPercent': listing.discountPercent,
      },
    );
    await loadListings();
  }

  void onTabSelected(int index) {
    if (index == currentTab.value) {
      return;
    }
    switch (index) {
      case PartnerBottomNav.reservations:
        Get.offNamed(Routes.PARTNER_DASHBOARD);
      case PartnerBottomNav.revenue:
        Get.offNamed(Routes.PARTNER_REVENUE);
      case PartnerBottomNav.myBusiness:
        Get.offNamed(Routes.PARTNER_MY_BUSINESS);
    }
  }
}
