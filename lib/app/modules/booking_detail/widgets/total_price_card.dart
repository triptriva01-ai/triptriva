import 'package:flutter/material.dart';

import '../../../data/models/booking_detail.dart';
import '../constants/booking_detail_constants.dart';
import '../controllers/booking_detail_controller.dart';
import 'bill_sheet.dart';
import 'detail_card.dart';

/// "Total Price" — headline figure, the charge summary, and the link that
/// opens the full bill.
class TotalPriceCard extends StatelessWidget {
  const TotalPriceCard({required this.detail, super.key});

  final BookingDetail detail;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  BookingDetailStrings.totalPrice,
                  style: BookingDetailStyle.cardTitle,
                ),
              ),
              Text(
                BookingDetailController.formatRupees(detail.total),
                style: BookingDetailStyle.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const FadingRule(),
          const SizedBox(height: 15),
          for (final charge in detail.charges)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      charge.label,
                      style: BookingDetailStyle.chargeLabel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    BookingDetailController.formatRupees(charge.amount),
                    style: BookingDetailStyle.chargeValue,
                  ),
                ],
              ),
            ),
          const FadingRule(),
          const SizedBox(height: 15),
          DetailLinkRow(
            icon: Icons.receipt_long_outlined,
            label: BookingDetailStrings.paymentDetails,
            onTap: () => BillSheet.show(context, detail),
            trailing: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: BookingDetailPalette.blue,
            ),
          ),
        ],
      ),
    );
  }
}
