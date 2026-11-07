import 'package:flutter/material.dart';

import '../../../data/models/booking_detail.dart';
import '../constants/booking_detail_constants.dart';
import '../controllers/booking_detail_controller.dart';
import 'detail_card.dart';

/// "View Your Bill" — the full charge breakdown, shown over a dimmed page.
class BillSheet extends StatelessWidget {
  const BillSheet({required this.detail, super.key});

  final BookingDetail detail;

  static Future<void> show(BuildContext context, BookingDetail detail) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: BookingDetailPalette.black.withValues(alpha: 0.3),
      // The breakdown can outgrow the screen on a small device with a large
      // font, so let the sheet scroll rather than clip.
      isScrollControlled: true,
      builder: (context) => BillSheet(detail: detail),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BookingDetailPalette.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BookingDetailSizes.sheetRadius),
        ),
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20)],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            BookingDetailSizes.pagePadding,
            30,
            BookingDetailSizes.pagePadding,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: BookingDetailPalette.black,
                  ),
                  SizedBox(width: 12),
                  Text(
                    BookingDetailStrings.viewYourBill,
                    style: TextStyle(
                      color: BookingDetailPalette.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              for (final line in detail.billLines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _BillRow(line: line),
                ),
              const SizedBox(height: 8),
              const FadingRule(),
              const SizedBox(height: 26),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      BookingDetailStrings.totalPrice,
                      style: BookingDetailStyle.billTotal,
                    ),
                  ),
                  Text(
                    BookingDetailController.formatRupees(detail.total),
                    style: BookingDetailStyle.billTotal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.line});

  final BillLine line;

  @override
  Widget build(BuildContext context) {
    final colour = line.isSaving
        ? BookingDetailPalette.saving
        : BookingDetailPalette.meta;
    final amount = BookingDetailController.formatRupees(line.amount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            line.label,
            style: BookingDetailStyle.billLabel.copyWith(color: colour),
          ),
        ),
        const SizedBox(width: 16),
        // Wrap so a struck-through original and the final amount stack on a
        // narrow screen instead of overflowing.
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 2,
          children: [
            if (line.originalAmount != null)
              Text(
                BookingDetailController.formatRupees(line.originalAmount!),
                style: BookingDetailStyle.billLabel.copyWith(
                  color: BookingDetailPalette.struck,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: BookingDetailPalette.struck,
                ),
              ),
            Text(
              line.isDeduction ? '- $amount' : amount,
              style: BookingDetailStyle.billValue.copyWith(color: colour),
            ),
          ],
        ),
      ],
    );
  }
}
