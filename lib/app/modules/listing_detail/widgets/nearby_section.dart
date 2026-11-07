import 'package:flutter/material.dart';

import '../../../data/models/listing.dart';
import '../../../widgets/listing/listing_card.dart';
import '../constants/listing_detail_constants.dart';

/// "Near By Tree House" — a horizontal rail of the shared [ListingCard].
class NearbySection extends StatelessWidget {
  const NearbySection({
    required this.title,
    required this.listings,
    required this.onListingTap,
    required this.onWishlistTap,
    super.key,
  });

  final String title;
  final List<Listing> listings;
  final ValueChanged<Listing> onListingTap;
  final ValueChanged<Listing> onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: ListingDetailStyle.sectionTitle,
        ),
        const SizedBox(height: 20),
        // A horizontal scroller needs a bounded cross-axis size; sizing the
        // Row to its content gives the cards their natural height instead.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final listing in listings) ...[
                SizedBox(
                  // The card fills whatever width it is given; the rail is
                  // what fixes it, so the same widget works in the grid too.
                  width: ListingDetailSizes.nearbyCardWidth,
                  child: ListingCard(
                    listing: listing,
                    onTap: () => onListingTap(listing),
                    onWishlistTap: () => onWishlistTap(listing),
                  ),
                ),
                const SizedBox(width: ListingDetailSizes.nearbyGap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
