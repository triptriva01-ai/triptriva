import 'package:flutter/material.dart';

import '../../../data/models/partner_activity.dart';
import '../../../widgets/partner/partner_theme.dart';

/// Slot-allocation card: how far ahead the listing is open, plus the button
/// that opens the calendar editor.
class SlotAllocationCard extends StatelessWidget {
  const SlotAllocationCard({
    required this.listing,
    required this.onEdit,
    super.key,
  });

  final PartnerActivity listing;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: PartnerDecoration.bookingCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 20,
                color: PartnerPalette.heading,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  listing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PartnerStyle.cardTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Wraps onto a second line on narrow screens rather than overflowing.
          Wrap(
            spacing: 20,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Currently open upto',
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                listing.openUntil.isEmpty ? '—' : listing.openUntil,
                style: PartnerStyle.cardMetaAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CardButton(
            icon: Icons.edit_calendar_outlined,
            label: 'Edit Allocation',
            onTap: onEdit,
          ),
        ],
      ),
    );
  }
}

/// Pricing card: original and final price side by side, with the discount type.
class PricingCard extends StatelessWidget {
  const PricingCard({
    required this.listing,
    required this.onEdit,
    super.key,
  });

  final PartnerActivity listing;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: PartnerDecoration.bookingCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 20,
                color: PartnerPalette.heading,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  listing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PartnerStyle.cardTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: PartnerGradients.prime.createShader,
                child: const Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: PartnerPalette.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                listing.discountType.isEmpty
                    ? 'No discount'
                    : listing.discountType,
                style: const TextStyle(
                  color: PartnerPalette.mutedStrong,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _PriceColumn(
                    label: 'Orginal Price',
                    value: listing.originalPrice,
                    struckThrough: true,
                  ),
                ),
                Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: PartnerPalette.hairline,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Expanded(
                  child: _PriceColumn(
                    label: 'Final Price',
                    value: listing.price,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CardButton(
            icon: Icons.edit_outlined,
            label: 'Edit Price and Discount',
            onTap: onEdit,
          ),
        ],
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.label,
    required this.value,
    this.struckThrough = false,
  });

  final String label;
  final double value;
  final bool struckThrough;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PartnerPalette.black,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '₹${value.toStringAsFixed(0)}/-',
          style: TextStyle(
            color: PartnerPalette.black,
            fontSize: 20,
            fontWeight: struckThrough ? FontWeight.w400 : FontWeight.w500,
            decoration: struckThrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: PartnerGradients.prime,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: PartnerPalette.white),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PartnerPalette.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
