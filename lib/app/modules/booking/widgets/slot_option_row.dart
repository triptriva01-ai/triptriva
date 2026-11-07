import 'package:flutter/material.dart';

import '../../../data/models/listing_detail.dart';
import '../constants/booking_constants.dart';

/// One bookable slot: "Day Trip | 11 AM - 05 PM" in a rounded white pill.
///
/// The selected pill loses its outline and gains the brand tint, matching the
/// Figma export where the chosen row reads as filled.
class SlotOptionRow extends StatelessWidget {
  const SlotOptionRow({
    required this.slot,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final ListingSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = slot.isAvailable;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          // A minimum, not a cap: the pill grows with the system font rather
          // than clipping its labels.
          constraints: const BoxConstraints(
            minHeight: BookingSizes.slotRowHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: BookingPalette.white,
            borderRadius: BorderRadius.circular(
              BookingSizes.slotRowRadius,
            ),
            border: Border.all(
              color: isSelected
                  ? BookingPalette.green
                  : BookingPalette.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Equal shares so the name and the time range both keep their
              // space however narrow the device.
              Expanded(
                child: Text(
                  slot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: BookingStyle.slotLabel,
                ),
              ),
              const SizedBox(width: BookingSizes.slotLabelGap),
              Container(
                width: BookingSizes.slotDividerWidth,
                height: BookingSizes.slotDividerHeight,
                color: BookingPalette.black,
              ),
              const SizedBox(width: BookingSizes.slotLabelGap),
              Expanded(
                child: Text(
                  slot.timeRange,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: BookingStyle.slotLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Get 1 hour for refreshing" — an optional extra offered by some stays.
class RefreshingRoomRow extends StatelessWidget {
  const RefreshingRoomRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: BookingSizes.slotRowHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BookingPalette.white,
          borderRadius: BorderRadius.circular(
            BookingSizes.slotRowRadius,
          ),
          border: Border.all(
            color: isSelected
                ? BookingPalette.green
                : BookingPalette.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected
                  ? BookingPalette.green
                  : BookingPalette.border,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: BookingStyle.slotLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
