import 'package:flutter/material.dart';

import '../constants/booking_detail_constants.dart';

/// [DetailCard], [FadingRule] and [BulletRow] are shared with the listing
/// detail screen, so they live under `widgets/detail/`. They are re-exported
/// here because every booking-detail widget reaches for them through this
/// file.
export '../../../widgets/detail/detail_card.dart'
    show BulletRow, DetailCard, FadingRule;

/// A blue text action with a leading icon: "Get Direction", "Download
/// invoice", "Go to page".
class DetailLinkRow extends StatelessWidget {
  const DetailLinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Chevron on the right for rows that open another screen or sheet.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: BookingDetailPalette.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BookingDetailStyle.link,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Square listing photo with a neutral placeholder.
class DetailThumbnail extends StatelessWidget {
  const DetailThumbnail({required this.imageUrl, required this.size, super.key});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BookingDetailSizes.thumbRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? const ColoredBox(
                color: Color(0xFFD9D9D9),
                child: Icon(
                  Icons.photo_outlined,
                  color: BookingDetailPalette.muted,
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFD9D9D9),
                  child: Icon(
                    Icons.photo_outlined,
                    color: BookingDetailPalette.muted,
                  ),
                ),
              ),
      ),
    );
  }
}
