import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/booking.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/booking_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../constants/reservations_constants.dart';

/// Which bookings the list is showing (FR-01).
enum BookingFilter { all, booked, completed }

/// Page 2 — Reservations.
class ReservationsController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();

  final searchController = TextEditingController();

  final bookings = <Booking>[].obs;
  final selectedFilter = BookingFilter.all.obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final currentTab = AppBottomNav.reservations.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_syncSearchQuery);
    loadBookings();
  }

  @override
  void onClose() {
    searchController
      ..removeListener(_syncSearchQuery)
      ..dispose();
    super.onClose();
  }

  void _syncSearchQuery() => searchQuery.value = searchController.text;

  Future<void> loadBookings() async {
    isLoading.value = true;
    try {
      final data = await _bookingService.getBookings(
        query: {'status': selectedFilter.value.name},
      );
      bookings.assignAll(
        data is List
            ? data.whereType<Map<String, dynamic>>().map(Booking.fromJson)
            : const <Booking>[],
      );
    } on ApiException catch (error) {
      Get.log('Bookings load failed: $error');
      _loadSampleBookings();
    } finally {
      isLoading.value = false;
    }
  }

  /// Bookings for the active tab and search term, grouped by date header.
  /// Call this inside an Obx builder so the reads register.
  List<BookingGroup> get visibleGroups {
    final filter = selectedFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    final matches = bookings.where((booking) {
      final matchesFilter = switch (filter) {
        BookingFilter.all => true,
        BookingFilter.booked => booking.status == BookingStatus.booked,
        BookingFilter.completed => booking.status == BookingStatus.completed,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      return booking.title.toLowerCase().contains(query) ||
          booking.bookingId.toLowerCase().contains(query);
    }).toList();

    final grouped = <String, List<Booking>>{};
    for (final booking in matches) {
      grouped.putIfAbsent(booking.groupLabel, () => []).add(booking);
    }

    return grouped.entries
        .map((entry) => BookingGroup(label: entry.key, bookings: entry.value))
        .toList();
  }

  void selectFilter(BookingFilter filter) {
    if (filter == selectedFilter.value) return;
    selectedFilter.value = filter;
    loadBookings();
  }

  /// FR-01 — tapping the arrow opens the booking detail page.
  ///
  /// The row itself is passed through so the detail screen can render its
  /// header immediately while the full payload loads.
  void openBooking(Booking booking) =>
      Get.toNamed(Routes.BOOKING_DETAIL, arguments: booking);

  void openDateFilter() => _pending('Date filter');

  void onTabSelected(int index) {
    if (index == currentTab.value) return;
    switch (index) {
      case AppBottomNav.explore:
        Get.offNamed(Routes.HOME);
      case AppBottomNav.wishlist:
        Get.offNamed(Routes.WISHLIST);
      case AppBottomNav.profile:
        Get.offNamed(Routes.PROFILE);
    }
  }

  void _pending(String feature) {
    Get.snackbar(
      ReservationsStrings.pendingTitle,
      ReservationsStrings.pendingMessage(feature),
      duration: ReservationsDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ---------------------------------------------------------------------
  // Development placeholder — remove once the backend serves real data.
  // ---------------------------------------------------------------------

  void _loadSampleBookings() {
    bookings.assignAll(const [
      Booking(
        id: '1',
        bookingId: '301928',
        title: 'Kayaking in Thrissur',
        people: 10,
        date: '11 march',
        timeSlot: '11pm-12pm',
        groupLabel: 'march 15',
      ),
      Booking(
        id: '2',
        bookingId: '301928',
        title: 'Kerala House Boat',
        people: 10,
        date: '11 march',
        timeSlot: '11pm-12pm',
        groupLabel: 'march 15',
      ),
      Booking(
        id: '3',
        bookingId: '301928',
        title: 'Tree hut in Thrissur',
        people: 10,
        date: '11 march',
        timeSlot: '11pm-12pm',
        groupLabel: 'march 15',
        status: BookingStatus.completed,
      ),
      Booking(
        id: '4',
        bookingId: '301928',
        title: 'Kayaking in Thrissur',
        people: 10,
        date: '11 march',
        timeSlot: '11pm-12pm',
        groupLabel: 'march 15',
        status: BookingStatus.completed,
      ),
    ]);
  }
}
