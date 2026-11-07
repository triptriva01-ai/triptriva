import 'package:get/get.dart';

import '../../../data/models/partner_booking.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/partner/partner_bottom_nav.dart';
import '../constants/partner_dashboard_constants.dart';

/// Which booking set the dashboard is showing (Sheet2 Page 02, FR-02).
enum BookingTab { today, all }

/// Partner Reservation Dashboard — partner-side Page 02.
class PartnerDashboardController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();

  final partnerName = PartnerStrings.placeholderName.obs;
  final selectedBookingTab = BookingTab.all.obs;
  final bookings = <PartnerBooking>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentTab = PartnerBottomNav.reservations.obs;

  /// Index into [categories]; 0 is "All".
  final selectedCategory = 0.obs;

  /// Bookings the partner has already checked in, by booking id.
  final confirmedIds = <String>{}.obs;

  static const categories = ['All', 'House boat', 'Stay', 'Adventure'];

  /// Backend listing type for each chip after "All".
  static const _categoryTypes = ['houseboat', 'stay', 'adventure'];

  bool get hasBookings => bookings.isNotEmpty;

  List<PartnerBooking> get visibleBookings {
    var rows = bookings.toList();
    if (selectedBookingTab.value == BookingTab.today) {
      rows = rows.where((booking) => booking.isToday).toList();
    }
    if (selectedCategory.value > 0) {
      final type = _categoryTypes[selectedCategory.value - 1];
      rows = rows.where((booking) => booking.listingType == type).toList();
    }
    return rows;
  }

  bool isConfirmed(PartnerBooking booking) =>
      booking.isCheckedIn ||
      confirmedIds.contains(booking.id) ||
      booking.isCompleted;

  @override
  void onInit() {
    super.onInit();
    _loadName();
    loadBookings();
  }

  Future<void> _loadName() async {
    final name = await _partnerService.displayName();
    if (name != null) partnerName.value = name;
  }

  /// FR-02 — reservation data refreshes whenever the selected tab changes.
  /// Cancelled bookings are left out: there's nothing for the partner to do.
  Future<void> loadBookings() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // The booking rows don't carry the listing type, so the category chips
      // match on the partner's own listings.
      final results = await Future.wait([
        _partnerService.getMyBookings(),
        _partnerService.getMyListings(),
      ]);
      final rows = results[0] as List<PartnerBooking>;
      final types = {
        for (final listing in results[1] as List) listing.id: listing.type,
      };

      bookings.assignAll(
        rows
            .where((booking) => !booking.isCancelled)
            .map((booking) =>
                booking.withListingType('${types[booking.listingId] ?? ''}')),
      );
    } on ApiException catch (error) {
      Get.log('Partner bookings load failed: $error');
      errorMessage.value = error.message;
      bookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectBookingTab(BookingTab tab) {
    if (tab == selectedBookingTab.value) {
      return;
    }
    selectedBookingTab.value = tab;
    loadBookings();
  }

  void selectBookingTabAt(int index) =>
      selectBookingTab(BookingTab.values[index]);

  void selectCategory(int index) => selectedCategory.value = index;

  /// FR-01 — notification icon opens the partner notifications page.
  void openNotifications() => Get.toNamed(Routes.PARTNER_NOTIFICATIONS);

  /// FR-01 — tapping the avatar/name opens the partner profile.
  void openProfile() => Get.toNamed(Routes.PARTNER_PROFILE);

  /// FR-03 — opens the manual slot creation form (partner Page 2.1).
  Future<void> addManualSlot() async {
    await Get.toNamed(Routes.PARTNER_MANUAL_BOOKING);
    await loadBookings();
  }

  /// FR-04 — check a guest in by their booking code (partner Page 2.2).
  Future<void> confirmBooking(PartnerBooking booking) async {
    final result = await Get.toNamed(
      Routes.PARTNER_CONFIRM_CUSTOMER,
      arguments: {
        'customerName': booking.guestName,
        'bookingId': booking.id,
        'date': booking.date,
        'slot': booking.slotLabel,
      },
    );
    if (result == true) {
      confirmedIds.add(booking.id);
    }
  }

  void onTabSelected(int index) {
    if (index == currentTab.value) {
      return;
    }
    switch (index) {
      case PartnerBottomNav.quickUpdates:
        Get.offNamed(Routes.PARTNER_QUICK_UPDATES);
      case PartnerBottomNav.revenue:
        Get.offNamed(Routes.PARTNER_REVENUE);
      case PartnerBottomNav.myBusiness:
        Get.offNamed(Routes.PARTNER_MY_BUSINESS);
    }
  }
}
