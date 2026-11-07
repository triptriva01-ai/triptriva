import 'package:flutter/material.dart';

import '../../data/models/listing.dart';
import 'listing_card.dart';
import 'listing_card_theme.dart';

/// Two-column grid of [ListingCard]s, shared by Home and Wishlist.
///
/// Built from `Row`s rather than a `GridView` with a `childAspectRatio` on
/// purpose: a fixed aspect ratio would clip the cards as soon as the system
/// font grows, whereas each row here simply takes the height of its tallest
/// card.
class ListingGrid extends StatelessWidget {
  const ListingGrid({
    required this.listings,
    required this.onListingTap,
    required this.onWishlistTap,
    this.rowGap = ListingCardSizes.rowGap,
    this.columnGap = ListingCardSizes.columnGap,
    super.key,
  });

  final List<Listing> listings;
  final ValueChanged<Listing> onListingTap;
  final ValueChanged<Listing> onWishlistTap;
  final double rowGap;
  final double columnGap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var index = 0; index < listings.length; index += 2) {
      final left = listings[index];
      final right = index + 1 < listings.length ? listings[index + 1] : null;

      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: rowGap));
      }

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _card(left)),
            SizedBox(width: columnGap),
            Expanded(
              child: right == null ? const SizedBox.shrink() : _card(right),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _card(Listing listing) {
    return ListingCard(
      listing: listing,
      onTap: () => onListingTap(listing),
      onWishlistTap: () => onWishlistTap(listing),
    );
  }
}
