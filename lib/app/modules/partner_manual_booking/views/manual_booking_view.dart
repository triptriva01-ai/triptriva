import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_fields.dart';
import '../../../widgets/calendar/month_calendar.dart';
import '../../../widgets/partner/partner_page_header.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/manual_booking_controller.dart';

/// Partner-side Page 2.1 — Manual Booking.
class ManualBookingView extends GetView<ManualBookingController> {
  const ManualBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartnerPalette.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            PartnerPageHeader(
              title: 'Manual Booking',
              onBack: controller.goBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PartnerSizes.pagePadding,
                  24,
                  PartnerSizes.pagePadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ListingPicker(controller: controller),
                    const SizedBox(height: 24),
                    const Text(
                      'Name of the customer',
                      style: PartnerStyle.formHeading,
                    ),
                    const SizedBox(height: 20),
                    PartnerTextField(
                      hint: 'Customer name',
                      controller: controller.customerName,
                    ),
                    const SizedBox(height: 12),
                    PartnerTextField(
                      hint: 'Phone number (optional)',
                      controller: controller.customerPhone,
                      keyboardType: TextInputType.phone,
                      maxLength: 20,
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => PartnerCounterRow(
                        label: 'Guests',
                        value: controller.guests.value,
                        onDecrement: controller.guests.value > 1
                            ? controller.decrementGuests
                            : null,
                        onIncrement: controller.incrementGuests,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Obx(() {
                      // Every observable the calendar depends on is read
                      // here, inside the builder. `styleFor` runs during the
                      // calendar's own build — outside this reactive scope —
                      // so reads in there would not be tracked and the grid
                      // would never repaint on selection.
                      final month = controller.visibleMonth.value;
                      final selected = controller.selectedDate.value;
                      final selectedKey = selected == null
                          ? null
                          : ManualBookingController.keyFor(selected);
                      final availability =
                          Map<String, SlotAvailability>.from(
                        controller.availability,
                      );

                      return MonthCalendar(
                        month: month,
                        onPreviousMonth: controller.previousMonth,
                        onNextMonth: controller.nextMonth,
                        onDayTap: controller.selectDate,
                        styleFor: (day) => _styleForDay(
                          day,
                          selectedKey,
                          availability,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    const CalendarLegend(
                      entries: [
                        (color: PartnerPalette.hairline, label: 'Full Filled'),
                        (color: PartnerPalette.headerGreen, label: 'offer'),
                        (color: PartnerPalette.blue, label: 'Season'),
                      ],
                    ),
                    _Sessions(controller: controller),
                  ],
                ),
              ),
            ),
            _Footer(controller: controller),
          ],
        ),
      ),
    );
  }

  /// Selection wins over availability so the partner can always see their pick.
  ///
  /// Takes plain values rather than reading the controller, so it can be
  /// called safely from outside the [Obx] scope.
  DayStyle _styleForDay(
    DateTime day,
    String? selectedKey,
    Map<String, SlotAvailability> availability,
  ) {
    final key = ManualBookingController.keyFor(day);
    if (selectedKey == key) {
      return const DayStyle(
        fill: PartnerPalette.headerGreen,
        textColor: PartnerPalette.white,
      );
    }

    return switch (availability[key] ?? SlotAvailability.open) {
      SlotAvailability.fullyFilled => const DayStyle(
          fill: PartnerPalette.hairline,
          textColor: PartnerPalette.white,
        ),
      SlotAvailability.offer =>
        const DayStyle(textColor: PartnerPalette.headerGreen),
      SlotAvailability.season =>
        const DayStyle(textColor: PartnerPalette.blue),
      SlotAvailability.closed =>
        const DayStyle(textColor: PartnerPalette.hairline),
      SlotAvailability.open => const DayStyle(),
    };
  }
}

/// Which live listing the walk-in is for. A single listing is just named.
class _ListingPicker extends StatelessWidget {
  const _ListingPicker({required this.controller});

  final ManualBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingListings.value) {
        return const LinearProgressIndicator(minHeight: 2);
      }
      final listings = controller.listings;
      if (listings.isEmpty) {
        return Text(
          'You have no live activity yet. Walk-in bookings can be added once '
          'an activity is approved.',
          style: PartnerStyle.rowCaption.copyWith(color: PartnerPalette.danger),
        );
      }
      final selected = controller.selectedListing.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity', style: PartnerStyle.formHeading),
          const SizedBox(height: 12),
          if (listings.length == 1)
            Text(listings.single.name, style: PartnerStyle.cardTitle)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final listing in listings)
                  ChoiceChip(
                    label: Text(listing.name),
                    selected: listing.id == selected?.id,
                    selectedColor:
                        PartnerPalette.headerGreen.withValues(alpha: 0.15),
                    onSelected: (_) => controller.selectListing(listing),
                  ),
              ],
            ),
        ],
      );
    });
  }
}

/// Session picker for a day sold by time slot.
class _Sessions extends StatelessWidget {
  const _Sessions({required this.controller});

  final ManualBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sessions = controller.sessionsForSelected;
      if (sessions.isEmpty) return const SizedBox.shrink();
      final selectedId = controller.selectedSessionId.value;
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Time slot', style: PartnerStyle.formHeading),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final session in sessions)
                  ChoiceChip(
                    label: Text(
                      session.isAvailable
                          ? '${session.label}  ·  ${session.availableUnits} left'
                          : '${session.label}  ·  full',
                    ),
                    selected: session.id == selectedId,
                    selectedColor:
                        PartnerPalette.headerGreen.withValues(alpha: 0.15),
                    onSelected: session.isAvailable
                        ? (_) => controller.selectSession(session)
                        : null,
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});

  final ManualBookingController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PartnerSizes.pagePadding,
          0,
          PartnerSizes.pagePadding,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PartnerHelpLink(onTap: controller.openHelp),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => PartnerPrimaryButton(
                  label: 'Manual booking',
                  expand: true,
                  height: 59,
                  onPressed: controller.canSubmit && !controller.isSaving.value
                      ? controller.submit
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
