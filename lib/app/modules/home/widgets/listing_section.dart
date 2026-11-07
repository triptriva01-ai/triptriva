import 'package:flutter/material.dart';

import '../../../data/models/listing.dart';
import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/listing/listing_grid.dart';

/// A titled section ("Most Popular", "Near By", "New Adventure") followed by
/// a hairline divider.
class ListingSection extends StatelessWidget {
  const ListingSection({
    required this.title,
    required this.listings,
    required this.controller,
    super.key,
  });

  final String title;
  final List<Listing> listings;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: HomeStyle.sectionTitle),
          const SizedBox(height: HomeSizes.sectionTitleToBody),
          ListingGrid(
            listings: listings,
            onListingTap: controller.openListing,
            onWishlistTap: controller.toggleWishlist,
          ),
          const SizedBox(height: HomeSizes.dividerTopPadding),
          const ColoredBox(
            color: HomePalette.divider,
            child: SizedBox(width: double.infinity, height: 1),
          ),
        ],
      ),
    );
  }
}
