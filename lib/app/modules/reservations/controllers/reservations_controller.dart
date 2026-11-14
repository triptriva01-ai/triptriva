import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/booking.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/booking_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_bottom_nav.dart';

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
  final errorMessage = ''.obs;

  /// Only bookings on this day, when set.
  final dateFilter = Rxn<DateTime>();
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
      final date = dateFilter.value;
      final data = await _bookingService.getBookings(
        query: {
          'status': selectedFilter.value.name,
          'limit': 50,
          if (date != null)
            'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-'
                '${date.day.toString().padLeft(2, '0')}',
        },
      );
      // A page (`{items: [...]}`) from the API.
      final items = data is Map ? data['items'] : data;
      bookings.assignAll(
        items is List
            ? items.whereType<Map<String, dynamic>>().map(Booking.fromJson)
            : const <Booking>[],
      );
      errorMessage.value = '';
    } on ApiException catch (error) {
      Get.log('Bookings load failed: $error');
      errorMessage.value = error.message;
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

  /// Picks a day to filter by; cancelling the picker clears the filter.
  Future<void> openDateFilter() async {
    final context = Get.context;
    if (context == null) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dateFilter.value ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    dateFilter.value = picked;
    loadBookings();
  }

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
}
