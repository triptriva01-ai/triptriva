import 'package:flutter/material.dart';

import '../../../data/models/listing.dart';
import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/listing/listing_grid.dart';

/// "Fresh up rooms" — a raised panel washed with the brand gradient, ending in
/// a "View all" link (`GET /api/listings/fresh/all`).
class FreshUpSection extends StatelessWidget {
  const FreshUpSection({
    required this.listings,
    required this.controller,
    super.key,
  });

  final List<Listing> listings;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeSizes.pagePadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: HomeGradients.prime,
          borderRadius: BorderRadius.circular(HomeSizes.freshRadius),
          boxShadow: HomeShadows.freshPanel,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: HomeGradients.freshWhiteFade(),
            borderRadius: BorderRadius.circular(HomeSizes.freshRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: HomeSizes.freshTopPadding,
              bottom: HomeSizes.freshBottomPadding,
            ),
            child: Column(
              children: [
                const Text(
                  HomeStrings.freshUpRooms,
                  textAlign: TextAlign.center,
                  style: HomeStyle.sectionTitle,
                ),
                const SizedBox(height: HomeSizes.sectionTitleToBody),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HomeSizes.freshInnerPadding,
                  ),
                  child: ListingGrid(
                    listings: listings,
                    rowGap: HomeSizes.freshRowGap,
                    onListingTap: controller.openListing,
                    onWishlistTap: controller.toggleWishlist,
                  ),
                ),
                const SizedBox(height: HomeSizes.freshToViewAll),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.openAllFresh,
                  child: const Text(
                    HomeStrings.viewAll,
                    textAlign: TextAlign.center,
                    style: HomeStyle.viewAll,
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
