import 'package:flutter/material.dart';

import '../../data/models/partner_activity.dart';
import 'partner_theme.dart';

/// One listing row on My Business: thumbnail, location, name, price and the
/// de-active badge when the listing is switched off.
class PartnerActivityCard extends StatelessWidget {
  const PartnerActivityCard({
    required this.activity,
    required this.onTap,
    super.key,
  });

  final PartnerActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
            decoration: PartnerDecoration.card(radius: 20),
            child: Row(
              children: [
                _Thumbnail(activity: activity),
                const SizedBox(width: 10),
                Expanded(
                  // De-active listings are dimmed rather than hidden, so the
                  // partner can still reopen them.
                  child: Opacity(
                    opacity: activity.isActive ? 1 : 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (activity.location.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 12,
                                color: PartnerPalette.headerGreen,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  activity.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: PartnerPalette.mutedStrong,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          activity.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PartnerPalette.black,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Wrap: the struck-through original price drops to a
                        // second line on a narrow card rather than overflowing.
                        Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '₹${activity.price.toStringAsFixed(0)}/-',
                              style: const TextStyle(
                                color: PartnerPalette.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (activity.hasDiscount)
                              Text(
                                '₹${activity.originalPrice.toStringAsFixed(0)}/-',
                                style: const TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: PartnerPalette.mutedStrong,
                ),
              ],
            ),
          ),
          if (!activity.isActive)
            Positioned(
              left: 0,
              top: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PartnerPalette.danger,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'De active',
                  style: TextStyle(
                    color: PartnerPalette.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.activity});

  final PartnerActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            PartnerPalette.white,
            activity.isActive
                ? PartnerPalette.headerGreen.withValues(alpha: 0.35)
                : const Color(0xFFB5B5B5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: activity.imageUrl.isEmpty
          ? const Icon(
              Icons.photo_outlined,
              size: 32,
              color: PartnerPalette.mutedStrong,
            )
          : Image.network(
              activity.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.photo_outlined,
                size: 32,
                color: PartnerPalette.mutedStrong,
              ),
            ),
    );
  }
}
