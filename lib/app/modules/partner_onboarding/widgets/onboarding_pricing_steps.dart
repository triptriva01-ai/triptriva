import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../modules/partner_manual_booking/controllers/manual_booking_controller.dart';
import '../../../widgets/partner/partner_fields.dart';
import '../../../widgets/calendar/month_calendar.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/partner_onboarding_controller.dart';
import 'onboarding_intro_steps.dart';

/// Step 3a — "Set a base prices", with the fee breakdown the partner can
/// expand to see exactly what they earn.
class BasePriceStep extends StatefulWidget {
  const BasePriceStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  State<BasePriceStep> createState() => _BasePriceStepState();
}

class _BasePriceStepState extends State<BasePriceStep> {
  late final TextEditingController _price = TextEditingController(
    text: widget.controller.basePriceValue.value.toStringAsFixed(0),
  );
  bool _showBreakdown = false;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Set a base prices',
          subtitle: 'It will be fixed for 1 year',
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PartnerPalette.white,
            borderRadius: BorderRadius.circular(30),
          ),
          // Full width rather than intrinsic: the field simply uses the space
          // the card gives it, so a six-figure price can never overflow.
          child: TextField(
            controller: _price,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) => controller.setBasePrice(
              double.tryParse(value) ?? controller.basePriceValue.value,
            ),
            style: const TextStyle(
              color: PartnerPalette.black,
              fontSize: 56,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixText: '₹',
              suffixText: '/-',
              prefixStyle: TextStyle(
                color: PartnerPalette.black,
                fontSize: 56,
                fontWeight: FontWeight.w600,
              ),
              suffixStyle: TextStyle(
                color: PartnerPalette.black,
                fontSize: 56,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: PartnerOutlinedButton(
            label: 'view similiar listing',
            height: 54,
            radius: 100,
            onPressed: () => Get.snackbar(
              'Similar listings',
              'Comparable pricing will open once search is wired up.',
              snackPosition: SnackPosition.BOTTOM,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _showBreakdown = !_showBreakdown),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showBreakdown ? 'Show less' : 'Show breakdown',
                  style: const TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  _showBreakdown
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: PartnerPalette.muted,
                ),
              ],
            ),
          ),
        ),
        if (_showBreakdown) ...[
          const SizedBox(height: 20),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                border: Border.all(color: PartnerPalette.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _BreakdownRow(
                    label: 'Base price',
                    value: controller.basePriceValue.value,
                  ),
                  const SizedBox(height: 26),
                  _BreakdownRow(
                    label: 'Guest service fee',
                    value: controller.guestPrice -
                        controller.basePriceValue.value,
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: PartnerPalette.hairline, height: 1),
                  ),
                  const SizedBox(height: 20),
                  _BreakdownRow(
                    label: 'Guest price before tax',
                    value: controller.guestPrice,
                    emphasised: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                border: Border.all(color: PartnerPalette.border),
                borderRadius: BorderRadius.circular(30),
              ),
              child: _BreakdownRow(
                label: 'You earn',
                value: controller.partnerEarnings,
                emphasised: true,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final double value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: PartnerPalette.black,
      fontSize: 18,
      fontWeight: emphasised ? FontWeight.w700 : FontWeight.w300,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          Text('₹${value.toStringAsFixed(0)}/-', style: style),
        ],
      ),
    );
  }
}

/// Step 3b — "Set a season prices": a percentage uplift applied to season days.
class SeasonPricingStep extends StatelessWidget {
  const SeasonPricingStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Set a season prices',
          subtitle: 'It will be fixed for 1 year',
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PartnerPalette.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₹${(controller.basePriceValue.value * controller.seasonPercent.value / 100).toStringAsFixed(0)}/-',
                style: const TextStyle(
                  color: PartnerPalette.black,
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Season slot percentage :',
                style: TextStyle(
                  color: Color(0xFF191C1D),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Obx(
              () => Container(
                height: 58,
                width: 102,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: PartnerPalette.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.seasonPercent.value.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: PartnerPalette.headerGreen,
              inactiveTrackColor: PartnerPalette.hairline,
              thumbColor: PartnerPalette.headerGreen,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: controller.seasonPercent.value,
              max: 200,
              onChanged: controller.setSeasonPercent,
            ),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: TextStyle(
                color: PartnerPalette.muted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '200%',
              style: TextStyle(
                color: PartnerPalette.muted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Step 3c — "Add discounts", including the season / off-season day pickers.
class DiscountsStep extends StatefulWidget {
  const DiscountsStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  State<DiscountsStep> createState() => _DiscountsStepState();
}

class _DiscountsStepState extends State<DiscountsStep> {
  bool _seasonExpanded = false;

  /// Which picker the calendar below is editing.
  bool _editingOffSeason = false;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Add discounts',
          subtitle: 'Helps you to gain more guest',
        ),
        Obx(
          () => PartnerValueRow(
            title: 'Starting discount',
            caption: 'Disappears after 3 days of booking',
            value: '${controller.startingDiscountPercent.value.toStringAsFixed(0)}%',
            onTap: () => _editPercent(
              context,
              title: 'Starting discount',
              current: controller.startingDiscountPercent,
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Divider(color: PartnerPalette.hairline, height: 1),
        const SizedBox(height: 30),
        Obx(
          () => PartnerValueRow(
            title: 'Off season discounts',
            caption: 'Applied on the days you mark below',
            value:
                '${controller.offSeasonDiscountPercent.value.toStringAsFixed(0)}%',
            onTap: () => _editPercent(
              context,
              title: 'Off season discount',
              current: controller.offSeasonDiscountPercent,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: PartnerDecoration.card(radius: 20),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _seasonExpanded = !_seasonExpanded),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: PartnerPalette.black,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Select you season',
                        style: TextStyle(
                          color: PartnerPalette.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Icon(
                      _seasonExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: PartnerPalette.muted,
                    ),
                  ],
                ),
              ),
              if (_seasonExpanded) ...[
                const SizedBox(height: 30),
                _SeasonRow(
                  label: 'Season',
                  selected: !_editingOffSeason,
                  onTap: () => setState(() => _editingOffSeason = false),
                ),
                const SizedBox(height: 20),
                _SeasonRow(
                  label: 'off season',
                  selected: _editingOffSeason,
                  onTap: () => setState(() => _editingOffSeason = true),
                ),
              ],
            ],
          ),
        ),
        if (_seasonExpanded) ...[
          const SizedBox(height: 30),
          Obx(() {
            // Read both sets here, inside the builder, so Obx actually
            // subscribes to them. `styleFor` runs later during the calendar's
            // own build, which is outside this reactive scope — reading them
            // in there would leave Obx observing nothing and throw.
            final season = controller.seasonDays.toSet();
            final offSeason = controller.offSeasonDays.toSet();

            return MonthCalendar(
              month: _month,
              onPreviousMonth: () => setState(
                () => _month = DateTime(_month.year, _month.month - 1),
              ),
              onNextMonth: () => setState(
                () => _month = DateTime(_month.year, _month.month + 1),
              ),
              onDayTap: (day) => controller.toggleSeasonDay(
                ManualBookingController.keyFor(day),
                offSeason: _editingOffSeason,
              ),
              styleFor: (day) {
                final key = ManualBookingController.keyFor(day);
                if (offSeason.contains(key)) {
                  return const DayStyle(
                    fill: PartnerPalette.danger,
                    textColor: PartnerPalette.white,
                  );
                }
                if (season.contains(key)) {
                  return const DayStyle(
                    fill: PartnerPalette.headerGreen,
                    textColor: PartnerPalette.white,
                  );
                }
                return const DayStyle();
              },
            );
          }),
          const SizedBox(height: 24),
          const CalendarLegend(
            entries: [
              (color: PartnerPalette.headerGreen, label: 'Season'),
              (color: PartnerPalette.danger, label: 'Off season'),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _editPercent(
    BuildContext context, {
    required String title,
    required RxDouble current,
  }) async {
    final field = TextEditingController(
      text: current.value.toStringAsFixed(0),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: field,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: '%'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(double.tryParse(field.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    field.dispose();
    if (value != null) {
      current.value = value.clamp(0, 100);
    }
  }
}

class _SeasonRow extends StatelessWidget {
  const _SeasonRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: PartnerPalette.black,
                fontSize: 18,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: PartnerGradients.prime,
              shape: BoxShape.circle,
            ),
            foregroundDecoration: BoxDecoration(
              color: PartnerPalette.white.withValues(alpha: selected ? 0 : 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              selected ? Icons.check : Icons.calendar_today_outlined,
              size: 18,
              color: selected ? PartnerPalette.white : PartnerPalette.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 3d — "Booking type": review each request, or let guests book instantly.
class BookingTypeStep extends StatelessWidget {
  const BookingTypeStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Booking type',
          subtitle: 'Your can change this at anytime',
        ),
        Obx(
          () => Column(
            children: [
              PartnerOptionCard(
                label: 'Approve the slot after reviewing',
                description: 'Approve the slot after you review the reservation',
                icon: Icons.fact_check_outlined,
                selected:
                    controller.bookingType.value == PartnerBookingType.reviewFirst,
                onTap: () => controller
                    .selectBookingType(PartnerBookingType.reviewFirst),
              ),
              const SizedBox(height: 20),
              PartnerOptionCard(
                label: 'Instant booking',
                description: 'Guest book automatically',
                icon: Icons.bolt_outlined,
                selected:
                    controller.bookingType.value == PartnerBookingType.instant,
                onTap: () =>
                    controller.selectBookingType(PartnerBookingType.instant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
