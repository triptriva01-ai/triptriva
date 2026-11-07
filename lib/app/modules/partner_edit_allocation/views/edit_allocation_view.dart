import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../partner_manual_booking/controllers/manual_booking_controller.dart';
import '../../../widgets/calendar/month_calendar.dart';
import '../../../widgets/partner/partner_page_header.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/edit_allocation_controller.dart';

/// Partner-side Page 3.2 — Edit Allocation.
class EditAllocationView extends GetView<EditAllocationController> {
  const EditAllocationView({super.key});

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
              title: 'Edit Allocation',
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
                    Obx(
                      () => Text(
                        controller.listingName.value,
                        style: PartnerStyle.cardTitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap a date to open or close it for bookings.',
                      style: PartnerStyle.rowCaption,
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      // Read the day sets here so Obx subscribes to them;
                      // `styleFor` runs inside the calendar's own build,
                      // outside this reactive scope.
                      final month = controller.visibleMonth.value;
                      final closed = controller.closedDays.toSet();
                      final full = controller.fullDays.toSet();

                      return MonthCalendar(
                        month: month,
                        onPreviousMonth: controller.previousMonth,
                        onNextMonth: controller.nextMonth,
                        onDayTap: controller.toggleDay,
                        styleFor: (day) => _styleForDay(day, closed, full),
                      );
                    }),
                    const SizedBox(height: 24),
                    const CalendarLegend(
                      entries: [
                        (color: PartnerPalette.hairline, label: 'Full Filled'),
                        (color: PartnerPalette.danger, label: 'Closed'),
                        (color: PartnerPalette.headerGreen, label: 'Open'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
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
                          label: 'Save',
                          expand: true,
                          height: 59,
                          onPressed:
                              controller.isSaving.value ? null : controller.save,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Takes plain sets rather than reading the controller, so it can be called
  /// safely from outside the [Obx] scope.
  DayStyle _styleForDay(
    DateTime day,
    Set<String> closed,
    Set<String> full,
  ) {
    final key = ManualBookingController.keyFor(day);
    if (full.contains(key)) {
      return const DayStyle(
        fill: PartnerPalette.hairline,
        textColor: PartnerPalette.white,
      );
    }
    if (closed.contains(key)) {
      return const DayStyle(
        fill: PartnerPalette.danger,
        textColor: PartnerPalette.white,
      );
    }
    return const DayStyle(textColor: PartnerPalette.headerGreen);
  }
}
