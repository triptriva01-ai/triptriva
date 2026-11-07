import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/banner_item.dart';
import '../../../data/models/listing.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/home_service.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../constants/home_constants.dart';

/// Page 1 — Home / Explore. Backs FR-01 … FR-09 of the user-side spec.
class HomeController extends GetxController {
  final HomeService _homeService = Get.find<HomeService>();
  final WishlistService _wishlistService = Get.find<WishlistService>();

  final categories = const [
    HomeStrings.categoryStay,
    HomeStrings.categoryHouseBoat,
    HomeStrings.categoryAdventure,
  ];

  final selectedCategory = 0.obs;
  final currentBanner = 0.obs;
  final currentTab = AppBottomNav.explore.obs;
  final isLoading = false.obs;

  final banners = <BannerItem>[].obs;
  final popular = <Listing>[].obs;
  final nearby = <Listing>[].obs;
  final fresh = <Listing>[].obs;
  final newAdventures = <Listing>[].obs;

  late final PageController bannerPageController;
  Timer? _autoSlideTimer;

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController(viewportFraction: 0.94);
    loadHome();
  }

  @override
  void onClose() {
    _autoSlideTimer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }

  /// Loads every home section. Falls back to sample content so the screen
  /// still renders while the backend is unavailable.
  Future<void> loadHome() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _homeService.getBanners(),
        _homeService.getPopular(),
        _homeService.getFresh(),
        _homeService.getNewAdventures(),
      ]);

      // assignAll (not `.value =`) keeps each Rx list backed by its own
      // growable list, so the sections stay independent and mutable.
      banners.assignAll(_parseBanners(results[0]));
      popular.assignAll(_parseListings(results[1]));
      nearby.assignAll(popular);
      fresh.assignAll(_parseListings(results[2]));
      newAdventures.assignAll(_parseListings(results[3]));
    } on ApiException catch (error) {
      Get.log('Home load failed: $error');
      _loadSampleContent();
    } finally {
      isLoading.value = false;
      _startAutoSlide();
    }
  }

  List<BannerItem> _parseBanners(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(BannerItem.fromJson)
        .toList();
  }

  List<Listing> _parseListings(dynamic data) {
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(Listing.fromJson).toList();
  }

  /// FR-05 — banners auto-slide after a fixed duration.
  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (banners.length < 2) return;

    _autoSlideTimer = Timer.periodic(HomeDurations.bannerAutoSlide, (_) {
      if (!bannerPageController.hasClients) return;
      final next = (currentBanner.value + 1) % banners.length;
      bannerPageController.animateToPage(
        next,
        duration: HomeDurations.bannerTransition,
        curve: Curves.easeOutCubic,
      );
    });
  }

  void onBannerChanged(int index) => currentBanner.value = index;

  /// FR-04 — selecting a category filters the listings.
  void selectCategory(int index) {
    if (index == selectedCategory.value) return;
    selectedCategory.value = index;
    loadHome();
  }

  /// FR-05 — banner call to action.
  void openBanner(BannerItem banner) => _pending(banner.ctaLabel);

  /// FR-05 — opens the product page for the card that was tapped.
  void openListing(Listing listing) =>
      Get.toNamed(Routes.LISTING_DETAIL, arguments: listing);

  /// Toggles a listing in the wishlist (Property page FR-01).
  Future<void> toggleWishlist(Listing listing) async {
    final lists = [popular, nearby, fresh, newAdventures];
    final nowWishlisted = !listing.isWishlisted;

    for (final list in lists) {
      final index = list.indexWhere((item) => item.id == listing.id);
      if (index != -1) {
        list[index] = list[index].copyWith(isWishlisted: nowWishlisted);
      }
    }

    try {
      if (nowWishlisted) {
        await _wishlistService.add(listing.id);
      } else {
        await _wishlistService.remove(listing.id);
      }
    } on ApiException catch (error) {
      // Keep the optimistic update; the backend is not wired up yet.
      Get.log('Wishlist toggle failed: $error');
    }
  }

  void openNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

  /// FR-03 — search field and voice search.
  void openSearch() => _pending('Search');

  void startVoiceSearch() => _pending('Voice search');

  /// FR-06 — advanced filters.
  void openFilters() => _pending('Filters');

  /// FR-07 — date picker.
  void openDatePicker() => _pending('Date selection');

  /// FR-08 — price range.
  void openPriceRange() => _pending(HomeStrings.priceRange);

  /// View all fresh-up rooms.
  void openAllFresh() => _pending(HomeStrings.freshUpRooms);

  void onTabSelected(int index) {
    if (index == currentTab.value) return;
    switch (index) {
      case AppBottomNav.reservations:
        Get.toNamed(Routes.RESERVATIONS);
      case AppBottomNav.wishlist:
        Get.toNamed(Routes.WISHLIST);
      case AppBottomNav.profile:
        Get.toNamed(Routes.PROFILE);
    }
  }

  void _pending(String feature) {
    Get.snackbar(
      HomeStrings.pendingTitle,
      HomeStrings.pendingMessage(feature),
      duration: HomeDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ---------------------------------------------------------------------
  // Development placeholders — remove once the backend serves real data.
  // ---------------------------------------------------------------------

  void _loadSampleContent() {
    banners.assignAll(const [
      BannerItem(id: 'b1', title: 'Resort'),
      BannerItem(id: 'b2', title: 'Kayaking'),
      BannerItem(id: 'b3', title: 'Houseboat'),
    ]);

    const sample = [
      Listing(
        id: 'l1',
        title: 'Tree House',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
      Listing(
        id: 'l2',
        title: 'Kayaking in Thrissur',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
      Listing(
        id: 'l3',
        title: 'HD Resort',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
      Listing(
        id: 'l4',
        title: 'Parasailing',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
    ];

    popular.assignAll(sample);
    nearby.assignAll(sample);
    newAdventures.assignAll(sample);
    fresh.assignAll(const [
      Listing(
        id: 'f1',
        title: 'Tree House',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
      Listing(
        id: 'f2',
        title: 'Tree House',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
      Listing(
        id: 'f3',
        title: 'Tree House',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
      Listing(
        id: 'f4',
        title: 'Tree House',
        location: 'Palarivattam',
        rating: 4.5,
        price: 500,
        originalPrice: 1200,
        discountPercent: 14,
      ),
    ]);
  }
}
