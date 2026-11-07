import 'package:flutter/material.dart';

import '../constants/booking_constants.dart';
import '../controllers/booking_controller.dart';

/// The bill breakdown that slides up over the bottom bar when the traveller
/// taps the price: charges, discounts, savings, then "To pay".
/// The bill takes plain values rather than the controller on purpose: it is
/// built from inside an `Obx` builder, so reading observables in its own
/// `build` would happen after that builder has finished and would not be
/// tracked — the sheet would then go stale when the party size changed.
class BookingBillSheet extends StatelessWidget {
  const BookingBillSheet({
    required this.chargeLabel,
    required this.basePrice,
    required this.discountedPrice,
    required this.pax,
    required this.totalDays,
    required this.couponDiscount,
    required this.savings,
    required this.total,
    required this.onCollapse,
    super.key,
  });

  /// "Day Trip Charge" — the chosen slot's name.
  final String chargeLabel;
  final double basePrice;
  final double discountedPrice;
  final int pax;
  final int totalDays;
  final double couponDiscount;
  final double savings;
  final double total;

  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final base = basePrice;
    final discounted = discountedPrice;
    final coupon = couponDiscount;
    final saved = savings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        BookingSizes.pagePadding,
        12,
        BookingSizes.pagePadding,
        BookingSizes.pagePadding,
      ),
      decoration: const BoxDecoration(
        color: BookingPalette.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BookingSizes.billSheetRadius),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCollapse,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: BookingPalette.black,
                  ),
                  SizedBox(width: 12),
                  Text(
                    BookingStrings.viewLess,
                    style: BookingStyle.viewLess,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: BookingSizes.billRowGap),
          _BillRow(
            label: chargeLabel,
            value: BookingController.formatRupees(discounted),
            originalValue: base > discounted
                ? BookingController.formatRupees(base)
                : null,
          ),
          const SizedBox(height: BookingSizes.billRowGap),
          _BillRow(
            label: BookingStrings.numberOfPeople,
            value: BookingStrings.times(pax),
          ),
          const SizedBox(height: BookingSizes.billRowGap),
          _BillRow(
            label: BookingStrings.totalDays,
            value: BookingStrings.times(totalDays),
          ),
          const SizedBox(height: BookingSizes.billRowGap),
          _BillRow(
            label: BookingStrings.couponDiscount,
            value: '- ${BookingController.formatRupees(coupon)}',
          ),
          const SizedBox(height: BookingSizes.billRowGap),
          _BillRow(
            label: BookingStrings.youHaveSaved,
            value: '- ${BookingController.formatRupees(saved)}',
            isSaving: true,
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 1,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: BookingGradients.rule),
            ),
          ),
          const SizedBox(height: 20),
          _BillRow(
            label: BookingStrings.toPay,
            value: BookingController.formatRupees(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.originalValue,
    this.isSaving = false,
    this.isTotal = false,
  });

  final String label;
  final String value;

  /// Struck-through price shown before the discounted one.
  final String? originalValue;
  final bool isSaving;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isTotal
        ? BookingStyle.billTotal
        : isSaving
            ? BookingStyle.billSaving
            : BookingStyle.billLabel;

    final valueStyle = isTotal
        ? BookingStyle.billTotal
        : isSaving
            ? BookingStyle.billSavingValue
            : BookingStyle.billValue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The label takes the slack so a long one wraps rather than pushing
        // the amount off the edge.
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 12),
        // Wraps so the struck price drops below the amount at a large
        // system font instead of overflowing.
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: [
            if (originalValue != null)
              Text(originalValue!, style: BookingStyle.billStruck),
            Text(value, style: valueStyle),
          ],
        ),
      ],
    );
  }
}
