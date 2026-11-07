import 'package:flutter/material.dart';

import '../constants/listing_detail_constants.dart';

/// Five stars with the last one half-filled when the score warrants it.
///
/// Figma draws the half star as a black/white split; `Icons.star_half` is the
/// same shape and follows the text colour.
class StarRow extends StatelessWidget {
  const StarRow({
    required this.rating,
    this.size = 13,
    this.gap = 4,
    this.color = ListingDetailPalette.black,
    super.key,
  });

  final double rating;
  final double size;
  final double gap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Wrap rather than Row: at a large system font the stars drop onto a
    // second line instead of overflowing a narrow card.
    return Wrap(
      spacing: gap,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(_iconFor(index), size: size, color: color),
      ],
    );
  }

  IconData _iconFor(int index) {
    final filled = rating - index;
    if (filled >= 0.75) return Icons.star;
    if (filled >= 0.25) return Icons.star_half;
    return Icons.star_border;
  }
}
