import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';
import '../../partner_manual_booking/controllers/manual_booking_controller.dart';

/// One date as the backend calendar reports it.
class _DayState {
  const _DayState({
    required this.isPublished,
    required this.isOpen,
    required this.totalUnits,
    required this.availableUnits,
  });

  final bool isPublished;

  /// Open for booking (published and not blocked).
  final bool isOpen;
  final int totalUnits;
  final int availableUnits;

  bool get isFull => isPublished && isOpen && totalUnits > 0 && availableUnits == 0;
}

/// Partner-side Page 3.2 — Edit Allocation.
///
/// The partner opens or closes individual days for one listing. Tapping a day
/// toggles it locally; "Save" sends only the days that changed.
class EditAllocationController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();

  final listingName = 'Listing'.obs;
  String _listingId = '';

  final visibleMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  /// Days currently shown as closed (saved state plus unsaved taps).
  final closedDays = <String>{}.obs;

  /// Days already fully booked; shown but not toggleable.
  final fullDays = <String>{}.obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  /// What the server last said, per day, for every month loaded so far.
  final _server = <String, _DayState>{};

  /// Days the partner tapped since the last save → wanted open (true) / closed.
  final _changes = <String, bool>{};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      _listingId = '${args['listingId'] ?? ''}';
      final name = args['listingName'];
      if (name is String && name.trim().isNotEmpty) {
        listingName.value = name.trim();
      }
    }
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    final month = visibleMonth.value;
    isLoading.value = true;
    try {
      final data = await _partnerService.getAvailability(
        _listingId,
        DateTime(month.year, month.month, 1),
        DateTime(month.year, month.month + 1, 0),
      );
      final days = data['days'];
      if (days is List) {
        for (final raw in days.whereType<Map>()) {
          final date = DateTime.tryParse('${raw['date']}');
          if (date == null) continue;
          _server[ManualBookingController.keyFor(date)] = _DayState(
            isPublished: raw['isPublished'] == true,
            isOpen: raw['isPublished'] == true && raw['isBlocked'] != true,
            totalUnits: (raw['totalUnits'] as num?)?.toInt() ?? 0,
            availableUnits: (raw['availableUnits'] as num?)?.toInt() ?? 0,
          );
        }
      }
      _rebuild();
    } on ApiException catch (error) {
      _snack(error.message);
    } finally {
      isLoading.value = false;
    }
  }

  /// Recomputes the two sets the calendar paints from server state + edits.
  void _rebuild() {
    final closed = <String>{};
    final full = <String>{};
    _server.forEach((key, day) {
      final open = _changes[key] ?? day.isOpen;
      if (!open) closed.add(key);
      if (open && day.isFull) full.add(key);
    });
    closedDays.assignAll(closed);
    fullDays.assignAll(full);
  }

  bool isDayClosed(DateTime day) =>
      closedDays.contains(ManualBookingController.keyFor(day));

  bool isFull(DateTime day) =>
      fullDays.contains(ManualBookingController.keyFor(day));

  void toggleDay(DateTime day) {
    final key = ManualBookingController.keyFor(day);
    final today = DateTime.now();
    if (day.isBefore(DateTime(today.year, today.month, today.day)) ||
        fullDays.contains(key) ||
        !_server.containsKey(key)) {
      return;
    }

    final wantOpen = closedDays.contains(key);
    if (wantOpen == _server[key]!.isOpen) {
      _changes.remove(key); // back to what's saved
    } else {
      _changes[key] = wantOpen;
    }
    _rebuild();
  }

  void previousMonth() {
    final month = visibleMonth.value;
    visibleMonth.value = DateTime(month.year, month.month - 1);
    _loadMonth();
  }

  void nextMonth() {
    final month = visibleMonth.value;
    visibleMonth.value = DateTime(month.year, month.month + 1);
    _loadMonth();
  }

  Future<void> save() async {
    if (_changes.isEmpty) {
      Get.back();
      return;
    }

    // A day that was never set up has no capacity yet: ask once how many
    // bookings each newly opened day can take.
    final needCapacity = _changes.entries
        .any((change) => change.value && !_server[change.key]!.isPublished);
    int? capacity;
    if (needCapacity) {
      capacity = await _askCapacity();
      if (capacity == null) return;
    }

    isSaving.value = true;
    final failed = <String>[];
    try {
      for (final change in Map.of(_changes).entries) {
        final date = DateTime.parse(change.key);
        final unpublished = !_server[change.key]!.isPublished;
        try {
          if (change.value && unpublished) {
            await _partnerService.setAvailability(
              _listingId,
              from: date,
              to: date,
              isAvailable: true,
              totalUnits: capacity,
            );
          } else {
            await _partnerService.setAvailability(
              _listingId,
              from: date,
              to: date,
              isAvailable: change.value,
            );
          }
          _changes.remove(change.key);
        } on ApiException catch (error) {
          Get.log('Allocation save failed for ${change.key}: $error');
          failed.add('${change.key}: ${error.message}');
        }
      }
    } finally {
      isSaving.value = false;
    }

    if (failed.isEmpty) {
      Get.back(result: true);
    } else {
      _snack('Some dates could not be saved:\n${failed.join('\n')}');
      await _loadMonth();
    }
  }

  Future<int?> _askCapacity() async {
    final field = TextEditingController(text: '1');
    final value = await Get.dialog<int>(
      AlertDialog(
        title: const Text('Bookings per day'),
        content: TextField(
          controller: field,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            helperText: 'How many bookings each newly opened day can take.',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final units = int.tryParse(field.text);
              if (units != null && units > 0) Get.back(result: units);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    field.dispose();
    return value;
  }

  void _snack(String message) => Get.snackbar(
        'Allocation',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );

  void goBack() => Get.back();

  void openHelp() => Get.toNamed(Routes.CUSTOMER_SUPPORT);
}
