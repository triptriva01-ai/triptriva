import 'package:flutter/material.dart';

import '../constants/booking_constants.dart';

/// "Check in date" and "Check out date" side by side, with the direction
/// arrow sitting between them.
///
/// Only shown for slots that run overnight; a day trip has a single date.
class DateRangeRow extends StatelessWidget {
  const DateRangeRow({
    required this.checkIn,
    required this.checkOut,
    super.key,
  });

  final String checkIn;
  final String checkOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _DateCard(
            label: BookingStrings.checkIn,
            value: checkIn,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: BookingSizes.slotRowHeight / 4,
          ),
          child: Icon(
            Icons.arrow_forward,
            size: 18,
            color: BookingPalette.black,
          ),
        ),
        Expanded(
          child: _DateCard(
            label: BookingStrings.checkOut,
            value: checkOut,
          ),
        ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BookingStyle.dateLabel,
        ),
        const SizedBox(height: BookingSizes.dateCardGap),
        Container(
          // A minimum, not a cap.
          constraints: const BoxConstraints(
            minHeight: BookingSizes.dateCardHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BookingPalette.white,
            borderRadius: BorderRadius.circular(
              BookingSizes.dateCardRadius,
            ),
            border: Border.all(color: BookingPalette.border),
          ),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: BookingStyle.dateLabel,
          ),
        ),
      ],
    );
  }
}
