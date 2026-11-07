import 'package:get/get.dart';

import '../../../data/models/partner_booking.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/partner/partner_bottom_nav.dart';

/// One payout line on the revenue list.
class RevenueEntry {
  const RevenueEntry({
    required this.customerName,
    required this.listingName,
    required this.amount,
    required this.date,
  });

  final String customerName;
  final String listingName;
  final double amount;
  final String date;
}

/// Partner-side Page 04 — Revenue.
class RevenueController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();

  final partnerName = 'Partner'.obs;
  final isLoading = false.obs;
  final currentTab = PartnerBottomNav.revenue.obs;

  final monthTotal = 0.0.obs;
  final yearTotal = 0.0.obs;
  final yearBookings = 0.obs;

  /// Month-on-month change, as a signed percentage.
  final monthChangePercent = 0.0.obs;

  final chartValues = <double>[].obs;
  final chartLabels = <String>[].obs;
  final entries = <RevenueEntry>[].obs;

  /// Collapses the booking list to the first few rows.
  final isExpanded = false.obs;

  static const _collapsedCount = 3;

  List<RevenueEntry> get visibleEntries => isExpanded.value
      ? entries.toList()
      : entries.take(_collapsedCount).toList();

  bool get hasMoreEntries => entries.length > _collapsedCount;

  @override
  void onInit() {
    super.onInit();
    _partnerService.displayName().then((name) {
      if (name != null) partnerName.value = name;
    });
    loadRevenue();
  }

  /// Totals from /me/revenue; the chart is this year's split by listing; the
  /// list is the latest paid bookings (amounts are what the guest paid, not a
  /// payout — no platform commission is defined yet).
  Future<void> loadRevenue() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _partnerService.getMyRevenue(),
        _partnerService.getMyBookings(),
      ]);
      final data = results[0] as Map<String, dynamic>;
      final bookings = results[1] as List<PartnerBooking>;

      final summary = data['summary'];
      if (summary is Map) {
        monthTotal.value = _toDouble(summary['thisMonthTotal']) ?? 0;
        yearTotal.value = _toDouble(summary['yearTotal']) ?? 0;
        yearBookings.value =
            (_toDouble(summary['totalBookingsThisYear']) ?? 0).toInt();
        // Null when last month had nothing to compare against.
        monthChangePercent.value = _toDouble(summary['growthPercent']) ?? 0;
      }

      final byListing = data['byListing'];
      final rows = byListing is List ? byListing.whereType<Map>().toList() : [];
      chartValues.assignAll(rows.map((row) => _toDouble(row['amount']) ?? 0));
      chartLabels.assignAll(rows.map((row) => _shortLabel('${row['listingTitle'] ?? ''}')));

      entries.assignAll(
        bookings.where((booking) => !booking.isCancelled).map(
              (booking) => RevenueEntry(
                customerName: booking.guestName,
                listingName: booking.listingTitle,
                amount: booking.amount,
                date: booking.dateLabel,
              ),
            ),
      );
    } on ApiException catch (error) {
      Get.log('Partner revenue load failed: $error');
      _reset();
      Get.snackbar('Revenue', error.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Chart axis labels have room for a word or so.
  static String _shortLabel(String title) =>
      title.length <= 8 ? title : '${title.substring(0, 7)}…';

  void _reset() {
    monthTotal.value = 0;
    yearTotal.value = 0;
    yearBookings.value = 0;
    monthChangePercent.value = 0;
    chartValues.clear();
    chartLabels.clear();
    entries.clear();
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Groups digits the Indian way: 2,84,500 rather than 284,500.
  static String formatRupees(double amount) {
    final whole = amount.round().toString();
    if (whole.length <= 3) {
      return '₹$whole';
    }
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      groups.insert(0, rest);
    }
    return '₹${groups.join(',')},$last3';
  }

  void toggleExpanded() => isExpanded.toggle();

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
      case PartnerBottomNav.myBusiness:
        Get.offNamed(Routes.PARTNER_MY_BUSINESS);
    }
  }
}
