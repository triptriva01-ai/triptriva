import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/booking/booking_bottom_bar.dart';
import '../../../widgets/calendar/month_calendar.dart';
import '../constants/booking_constants.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_bill_sheet.dart';
import '../widgets/date_range_row.dart';
import '../widgets/pax_selector.dart';
import '../widgets/slot_option_row.dart';

/// Booking flow: date and slot, then party size.
class BookingView extends GetView<BookingController> {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: BookingPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: BookingPalette.white,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            const _Hero(),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(onBack: controller.goBack),
                  Expanded(
                    child: Obx(
                      () => controller.step.value == BookingStep.dateAndSlot
                          ? _DateAndSlotStep(controller: controller)
                          : _PeopleStep(controller: controller),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Obx(() => _buildBottomBar(controller)),
      ),
    );
  }
}

/// The listing photo behind the top of the sheet.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // A bounded box holding an image, never text.
      height: BookingSizes.heroHeight,
      width: double.infinity,
      child: const ColoredBox(color: BookingPalette.placeholder),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BookingSizes.pagePadding,
        12,
        BookingSizes.pagePadding,
        12,
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: Container(
              width: BookingSizes.circleButtonSize,
              height: BookingSizes.circleButtonSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BookingPalette.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: BookingPalette.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: BookingSizes.circleIconSize,
                color: BookingPalette.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The white sheet the steps are drawn on.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BookingPalette.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BookingSizes.sheetRadius),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          BookingSizes.pagePadding,
          BookingSizes.sectionGap,
          BookingSizes.pagePadding,
          BookingSizes.bodyBottomPadding,
        ),
        children: children,
      ),
    );
  }
}

/// Centred heading with a leading icon, e.g. "Select a date".
class _Heading extends StatelessWidget {
  const _Heading({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Wrap rather than Row: the label drops below the icon at a large system
    // font instead of overflowing.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: BookingSizes.headingGap,
      runSpacing: 8,
      children: [
        Icon(
          icon,
          size: BookingSizes.headingIconSize,
          color: BookingPalette.black,
        ),
        Text(label, style: BookingStyle.heading),
      ],
    );
  }
}

class _DateAndSlotStep extends StatelessWidget {
  const _DateAndSlotStep({required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      children: [
        const _Heading(
          icon: Icons.calendar_month,
          label: BookingStrings.selectDate,
        ),
        const SizedBox(height: BookingSizes.headingToBody),
        Obx(() {
          // Every observable the calendar depends on is read here, in the
          // builder body — reads inside `styleFor` would not be tracked.
          final month = controller.month.value;
          final selected = controller.selectedDate.value;
          final full = controller.fullDays.toSet();
          final offer = controller.offerDays.toSet();
          final season = controller.seasonDays.toSet();

          return MonthCalendar(
            month: month,
            onPreviousMonth: controller.previousMonth,
            onNextMonth: controller.nextMonth,
            onDayTap: controller.selectDate,
            styleFor: (day) {
              final key = BookingController.formatDate(day);
              final isSelected = selected != null &&
                  BookingController.formatDate(selected) == key;

              if (isSelected) {
                return const DayStyle(
                  fill: BookingPalette.offer,
                  textColor: BookingPalette.white,
                );
              }
              if (full.contains(key)) {
                return const DayStyle(textColor: BookingPalette.full);
              }
              if (offer.contains(key)) {
                return const DayStyle(textColor: BookingPalette.offer);
              }
              if (season.contains(key)) {
                return const DayStyle(textColor: BookingPalette.season);
              }
              return const DayStyle();
            },
          );
        }),
        const SizedBox(height: BookingSizes.legendToCalendar),
        const CalendarLegend(
          entries: [
            (color: BookingPalette.full, label: BookingStrings.legendFull),
            (color: BookingPalette.offer, label: BookingStrings.legendOffer),
            (
              color: BookingPalette.season,
              label: BookingStrings.legendSeason,
            ),
          ],
        ),
        const SizedBox(height: BookingSizes.sectionGap),
        Obx(() {
          if (!controller.needsDateRange) {
            return const SizedBox.shrink();
          }
          final checkIn = controller.selectedDate.value;
          final checkOut = controller.checkOutDate.value;
          if (checkIn == null || checkOut == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(
              bottom: BookingSizes.sectionGap,
            ),
            child: DateRangeRow(
              checkIn: BookingController.formatLong(checkIn),
              checkOut: BookingController.formatLong(checkOut),
            ),
          );
        }),
        const _Heading(
          icon: Icons.access_time,
          label: BookingStrings.selectSlot,
        ),
        const SizedBox(height: BookingSizes.headingToBody),
        Obx(() {
          final slots = controller.slots.toList();
          final selected = controller.selectedSlot.value;

          return Column(
            children: [
              for (final slot in slots) ...[
                SlotOptionRow(
                  slot: slot,
                  isSelected: selected?.id == slot.id,
                  onTap: () => controller.selectSlot(slot),
                ),
                const SizedBox(height: BookingSizes.slotRowGap),
              ],
            ],
          );
        }),
        Obx(() {
          final note = controller.listing.value?.refreshingRoomNote ?? '';
          if (note.isEmpty) {
            return const SizedBox.shrink();
          }
          return RefreshingRoomRow(
            label: note,
            isSelected: controller.wantsRefreshingRoom.value,
            onTap: controller.toggleRefreshingRoom,
          );
        }),
      ],
    );
  }
}

class _PeopleStep extends StatelessWidget {
  const _PeopleStep({required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      children: [
        const _Heading(
          icon: Icons.groups_outlined,
          label: BookingStrings.numberOfPeople,
        ),
        const SizedBox(height: BookingSizes.headingToBody),
        Obx(() {
          final detail = controller.listing.value;
          return PaxSelector(
            value: controller.pax.value,
            min: detail?.minPax ?? 1,
            max: detail?.maxPax ?? 60,
            onChanged: controller.setPax,
          );
        }),
      ],
    );
  }
}

/// The sticky footer, and the bill sheet above it once it is expanded.
///
/// A function rather than a widget on purpose: it is called from inside an
/// `Obx` builder, so the observable reads below happen while that builder is
/// running and are tracked. A `StatelessWidget` would defer them to its own
/// `build`, leaving the `Obx` watching nothing.
Widget _buildBottomBar(BookingController controller) {
  final isPeopleStep = controller.step.value == BookingStep.people;
  final listing = controller.listing.value;
  final slot = controller.selectedSlot.value;
  final canContinue = controller.canContinue;
  final isBillExpanded = controller.isBillExpanded.value;

  final bar = BookingBottomBar(
    label: isPeopleStep ? BookingStrings.bookNow : BookingStrings.reserve,
    note: listing?.cancellationNote,
    // Only the people step shows the price; before a slot is picked there
    // is nothing to price.
    priceCaption: isPeopleStep && slot != null
        ? BookingStrings.forSlot(slot.name)
        : null,
    price: isPeopleStep
        ? BookingController.formatRupees(controller.total)
        : null,
    originalPrice: isPeopleStep &&
            controller.basePrice.value > controller.discountedPrice.value
        ? BookingController.formatRupees(controller.basePrice.value)
        : null,
    onPriceTap: isPeopleStep ? controller.toggleBill : null,
    isPriceExpanded: isBillExpanded,
    enabled: isPeopleStep ? !controller.isBooking.value : canContinue,
    onPressed: isPeopleStep
        ? controller.book
        : (canContinue ? controller.continueToPeople : null),
  );

  if (!isBillExpanded) {
    return bar;
  }

  // The sheet rides above the bar, and both size to their content. Its
  // values are read here, inside the Obx builder, so the bill refreshes
  // whenever the party size or the pricing changes.
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      BookingBillSheet(
        chargeLabel: slot == null
            ? BookingStrings.dayTripCharge
            : '${slot.name} Charge',
        basePrice: controller.basePrice.value,
        discountedPrice: controller.discountedPrice.value,
        pax: controller.pax.value,
        totalDays: controller.totalDays,
        couponDiscount: controller.couponDiscount.value,
        savings: controller.savings.value,
        total: controller.total,
        onCollapse: controller.toggleBill,
      ),
      bar,
    ],
  );
}
