import 'package:flutter/material.dart';

import '../../data/models/partner_booking.dart';
import 'partner_theme.dart';

/// One reservation on the partner dashboard: status badge and customer at the
/// top, listing name in the middle, then date, slot and the confirm action.
class PartnerBookingCard extends StatelessWidget {
  const PartnerBookingCard({
    required this.booking,
    required this.customerName,
    required this.onConfirm,
    this.customerAvatarUrl = '',
    super.key,
  });

  final PartnerBooking booking;
  final String customerName;
  final String customerAvatarUrl;

  /// Null once the booking is confirmed — the action becomes a static label.
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final completed = booking.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: PartnerDecoration.bookingCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  completed ? 'Completed' : 'Booked',
                  style: completed
                      ? PartnerStyle.statusCompleted
                      : PartnerStyle.statusBooked,
                ),
              ),
              Flexible(
                child: Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PartnerStyle.customerName,
                ),
              ),
              const SizedBox(width: 6),
              PartnerAvatar(imageUrl: customerAvatarUrl, size: 30),
            ],
          ),
          const SizedBox(height: 16),
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
                  booking.listingTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PartnerStyle.cardTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(booking.dateLabel, style: PartnerStyle.cardMeta),
              if (booking.slotLabel.isNotEmpty)
                Text(booking.slotLabel, style: PartnerStyle.cardMeta),
              Text('${booking.pax} guests', style: PartnerStyle.cardMeta),
              if (onConfirm != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onConfirm,
                  child: const Text(
                    'Click to Confirm',
                    style: PartnerStyle.cardAction,
                  ),
                )
              else
                const Text('Confirmed', style: PartnerStyle.cardMeta),
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular customer photo with an icon fallback while no image is available.
class PartnerAvatar extends StatelessWidget {
  const PartnerAvatar({required this.imageUrl, this.size = 30, super.key});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: PartnerPalette.hairline,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: PartnerPalette.mutedStrong,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => PartnerAvatar(imageUrl: '', size: size),
      ),
    );
  }
}

/// Horizontal category filter: All / House boat / Stay / Adventure. The active
/// chip is painted with the brand gradient.
class PartnerCategoryChips extends StatelessWidget {
  const PartnerCategoryChips({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // A scrolling Row rather than a horizontal ListView: it takes its height
    // from the chips, so a larger system font grows the strip instead of
    // needing a fixed height that would clip it.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: PartnerSizes.pagePadding,
      ),
      child: Row(
        children: [
          for (var index = 0; index < categories.length; index++) ...[
            if (index > 0) const SizedBox(width: 10),
            _CategoryChip(
              label: categories[index],
              isActive: index == selectedIndex,
              onTap: () => onSelected(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: TextStyle(
        color: isActive ? PartnerPalette.white : PartnerPalette.inactiveTab,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 33),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: isActive
            ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: PartnerGradients.prime.createShader,
                child: text,
              )
            : text,
      ),
    );
  }
}
