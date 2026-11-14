import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/listing.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../constants/wishlist_constants.dart';

/// Page 3 — Wishlist.
///
/// Everything the traveller has hearted, narrowed by a category dropdown and
/// a search box. Unhearting a card removes it from the server and from the
/// list in one gesture.
class WishlistController extends GetxController {
  final WishlistService _wishlistService = Get.find<WishlistService>();

  final searchController = TextEditingController();

  final listings = <Listing>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final currentTab = AppBottomNav.wishlist.obs;

  /// Category dropdown. Null means "everything".
  final selectedCategory = Rxn<String>();

  static const categories = <String>[
    WishlistStrings.categoryStay,
    WishlistStrings.categoryHouseBoat,
    WishlistStrings.categoryAdventure,
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_syncSearchQuery);
    loadWishlist();
  }

  @override
  void onClose() {
    searchController
      ..removeListener(_syncSearchQuery)
      ..dispose();
    super.onClose();
  }

  void _syncSearchQuery() => searchQuery.value = searchController.text;

  Future<void> loadWishlist() async {
    isLoading.value = true;
    try {
      final category = selectedCategory.value;
      final data = await _wishlistService.getWishlist(
        query: category == null ? null : {'category': category},
      );
      // `[{addedAt, listing: {...}}]` — every row is saved, so the heart is on.
      listings.assignAll(
        data is List
            ? data.whereType<Map<String, dynamic>>().map((item) {
                final listing = item['listing'];
                return Listing.fromJson(
                  listing is Map<String, dynamic> ? listing : item,
                ).copyWith(isWishlisted: true);
              })
            : const <Listing>[],
      );
      errorMessage.value = '';
    } on ApiException catch (error) {
      Get.log('Wishlist load failed: $error');
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  /// The saved listings matching the current search term.
  ///
  /// Read this inside an `Obx` builder — the observable reads happen here, so
  /// calling it from the builder body is what registers them.
  List<Listing> get visibleListings {
    final query = searchQuery.value.trim().toLowerCase();
    final all = listings.toList();
    if (query.isEmpty) {
      return all;
    }
    return all
        .where(
          (listing) =>
              listing.title.toLowerCase().contains(query) ||
              listing.location.toLowerCase().contains(query),
        )
        .toList();
  }

  void selectCategory(String? category) {
    if (category == selectedCategory.value) return;
    selectedCategory.value = category;
    loadWishlist();
  }

  /// Unhearting removes the listing. The row disappears straight away and
  /// comes back if the request fails, so the tap always feels instant.
  Future<void> removeFromWishlist(Listing listing) async {
    final index = listings.indexWhere((item) => item.id == listing.id);
    if (index < 0) return;

    final removed = listings.removeAt(index);
    try {
      await _wishlistService.remove(listing.id);
    } on ApiException catch (error) {
      Get.log('Wishlist remove failed: $error');
      listings.insert(index, removed);
      Get.snackbar(
        WishlistStrings.pendingTitle,
        error.message,
        duration: WishlistDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void goBack() => Get.back();

  /// Opens the product page for the saved listing.
  void openListing(Listing listing) =>
      Get.toNamed(Routes.LISTING_DETAIL, arguments: listing);

  void onTabSelected(int index) {
    if (index == currentTab.value) return;
    switch (index) {
      case AppBottomNav.explore:
        Get.offNamed(Routes.HOME);
      case AppBottomNav.reservations:
        Get.offNamed(Routes.RESERVATIONS);
      case AppBottomNav.profile:
        Get.offNamed(Routes.PROFILE);
    }
  }
}
