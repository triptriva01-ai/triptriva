import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/app_bottom_nav.dart';
import '../../../widgets/listing/listing_grid.dart';
import '../constants/wishlist_constants.dart';
import '../controllers/wishlist_controller.dart';
import '../widgets/no_more_wishes.dart';
import '../widgets/wishlist_filter_bar.dart';
import '../widgets/wishlist_header.dart';

/// Page 3 — Wishlist.
class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: WishlistPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: WishlistPalette.white,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WishlistSizes.pagePadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: WishlistSizes.headerTop),
                WishlistHeader(onBack: controller.goBack),
                const SizedBox(height: WishlistSizes.headerToFilters),
                WishlistFilterBar(controller: controller),
                const SizedBox(height: WishlistSizes.filtersToGrid),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final listings = controller.visibleListings;

                    return RefreshIndicator(
                      onRefresh: controller.loadWishlist,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          bottom: WishlistSizes.listBottomPadding,
                        ),
                        children: [
                          if (listings.isEmpty)
                            // Centred in the viewport rather than in a fixed
                            // box, so it sits well on any screen height.
                            const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: NoMoreWishes(showIllustration: true),
                            )
                          else ...[
                            ListingGrid(
                              listings: listings,
                              onListingTap: controller.openListing,
                              onWishlistTap: controller.removeFromWishlist,
                              rowGap: WishlistSizes.gridRowGap,
                              columnGap: WishlistSizes.gridColumnGap,
                            ),
                            const SizedBox(height: WishlistSizes.gridToFooter),
                            const WishlistDivider(),
                            const SizedBox(
                              height: WishlistSizes.dividerToLabel,
                            ),
                            const NoMoreWishes(),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => AppBottomNav(
            currentIndex: controller.currentTab.value,
            onTap: controller.onTabSelected,
          ),
        ),
      ),
    );
  }
}
