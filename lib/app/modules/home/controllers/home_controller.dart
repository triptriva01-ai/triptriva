import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/banner_item.dart';
import '../../../data/models/listing.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/geo_service.dart';
import '../../../data/services/home_service.dart';
import '../../../data/services/search_service.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../../search/controllers/search_controller.dart' show SearchArgs;
import '../constants/home_constants.dart';

/// The pop-ups that open under the home filter row.
enum HomeFilterPanel { filter, calendar, price }

/// Page 1 — Home / Explore. Backs FR-01 … FR-09 of the user-side spec.
class HomeController extends GetxController {
  final HomeService _homeService = Get.find<HomeService>();
  final WishlistService _wishlistService = Get.find<WishlistService>();
  final SearchService _searchService = Get.find<SearchService>();
  final GeoService _geoService = Get.find<GeoService>();

  final categories = const [
    HomeStrings.categoryStay,
    HomeStrings.categoryHouseBoat,
    HomeStrings.categoryAdventure,
  ];

  final selectedCategory = 0.obs;
  final currentBanner = 0.obs;
  final currentTab = AppBottomNav.explore.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

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
    minPriceController.dispose();
    maxPriceController.dispose();
    super.onClose();
  }

  /// API listing type for each entry of [categories].
  static const categoryTypes = ['stay', 'houseboat', 'adventure'];

  String get selectedType => categoryTypes[selectedCategory.value];

  /// Loads every home section for the selected category, applying the
  /// filter-row choices.
  Future<void> loadHome() async {
    isLoading.value = true;
    try {
      final type = selectedType;
      final point = await _geoService.locationIfAllowed();
      final results = await Future.wait([
        _homeService.getFeed(lat: point?.latitude, lng: point?.longitude),
        _section(type, sort: 'popular'),
        point == null
            ? _section(type, sort: 'rating')
            : _homeService.getNearby(
                lat: point.latitude,
                lng: point.longitude,
                type: type,
                limit: _sectionSize,
              ),
        // "Fresh up rooms" are stays, whatever the category.
        _section('stay', sort: 'newest'),
        _section(type, sort: 'newest'),
      ]);

      final feed = results[0];
      // assignAll (not `.value =`) keeps each Rx list backed by its own
      // growable list, so the sections stay independent and mutable.
      banners.assignAll(
        _parseBanners(feed is Map ? feed['banners'] : null),
      );
      popular.assignAll(_parseListings(results[1]));
      nearby.assignAll(_parseListings(results[2]));
      fresh.assignAll(_parseListings(results[3]));
      newAdventures.assignAll(_parseListings(results[4]));
      errorMessage.value = '';
    } on ApiException catch (error) {
      Get.log('Home load failed: $error');
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
      _startAutoSlide();
    }
  }

  static const _sectionSize = 4;

  /// One rail. With a date picked, only listings open that day; otherwise
  /// the price and capacity filters apply.
  Future<dynamic> _section(String type, {required String sort}) {
    final date = selectedDate.value;
    if (date != null) {
      return _searchService.available(
        date: _isoDate(date),
        category: type,
        limit: _sectionSize,
      );
    }
    final (min, max) = _priceBounds();
    return _homeService.getListings(query: {
      'type': type,
      'sort': sort,
      'limit': _sectionSize,
      'minPrice': ?min,
      'maxPrice': ?max,
      'guests': ?_guests(),
    });
  }

  static String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// The preset band, else whatever was typed under Above / Below.
  (num?, num?) _priceBounds() {
    switch (selectedPrice.value) {
      case 0:
        return (null, 500);
      case 1:
        return (500, 1000);
      case 2:
        return (1000, 5000);
      case 3:
        return (5000, null);
    }
    return (
      num.tryParse(minPriceController.text.trim()),
      num.tryParse(maxPriceController.text.trim()),
    );
  }

  /// "30 person capacity" → 30; "couple boat" → 2.
  int? _guests() => switch (selectedCapacity.value) {
        0 => 30,
        1 => 20,
        2 => 10,
        3 => 2,
        _ => null,
      };

  List<BannerItem> _parseBanners(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(BannerItem.fromJson)
        .toList();
  }

  /// Accepts a plain list or a page (`{items: [...]}`).
  List<Listing> _parseListings(dynamic data) {
    final items = data is Map ? data['items'] : data;
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Listing.fromJson)
        .toList();
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
  void openBanner(BannerItem banner) {
    final value = banner.targetValue ?? '';
    switch (banner.targetType) {
      case 'listing' when value.isNotEmpty:
        Get.toNamed(Routes.LISTING_DETAIL, arguments: value);
      case 'category':
        final index = categoryTypes.indexOf(value);
        if (index >= 0) selectCategory(index);
      case 'search' when value.isNotEmpty:
        Get.toNamed(Routes.SEARCH, arguments: SearchArgs(query: value));
      default:
        openSearch();
    }
  }

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
      Get.log('Wishlist toggle failed: $error');
      // Put the hearts back the way the server has them.
      for (final list in lists) {
        final index = list.indexWhere((item) => item.id == listing.id);
        if (index != -1) {
          list[index] = list[index].copyWith(isWishlisted: !nowWishlisted);
        }
      }
      Get.snackbar(
        HomeStrings.wishlistFailed,
        error.message,
        duration: HomeDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

  /// FR-03 — search field and voice search.
  void openSearch() {
    closePanel();
    Get.toNamed(Routes.SEARCH);
  }

  void startVoiceSearch() => _pending('Voice search');

  // ── FR-06 … FR-08: the pop-ups under the filter row ────────────────

  /// Which pop-up is open under the filter row, if any.
  final openPanel = Rxn<HomeFilterPanel>();

  /// Month the calendar pop-up is showing.
  final calendarMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final selectedDate = Rxn<DateTime>();

  /// Index into [HomeStrings.priceOptions]; null when none is picked.
  final selectedPrice = RxnInt();
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  /// Index into [HomeStrings.capacityOptions]; null when none is picked.
  final selectedCapacity = RxnInt();

  void _toggle(HomeFilterPanel panel) =>
      openPanel.value = openPanel.value == panel ? null : panel;

  /// FR-06 — advanced filters.
  void openFilters() => _toggle(HomeFilterPanel.filter);

  /// FR-07 — date picker.
  void openDatePicker() => _toggle(HomeFilterPanel.calendar);

  /// FR-08 — price range.
  void openPriceRange() => _toggle(HomeFilterPanel.price);

  void closePanel() {
    final wasPrice = openPanel.value == HomeFilterPanel.price;
    openPanel.value = null;
    // Typed bounds apply when the price pop-up closes.
    if (wasPrice && selectedPrice.value == null) loadHome();
  }

  void previousCalendarMonth() {
    final current = calendarMonth.value;
    calendarMonth.value = DateTime(current.year, current.month - 1);
  }

  void nextCalendarMonth() {
    final current = calendarMonth.value;
    calendarMonth.value = DateTime(current.year, current.month + 1);
  }

  /// Picking the chosen day again clears the date filter.
  void selectDate(DateTime day) {
    final current = selectedDate.value;
    selectedDate.value =
        current != null && DateUtils.isSameDay(current, day) ? null : day;
    openPanel.value = null;
    loadHome();
  }

  void selectPrice(int index) {
    selectedPrice.value = selectedPrice.value == index ? null : index;
    minPriceController.clear();
    maxPriceController.clear();
    loadHome();
  }

  /// Typing a custom bound replaces the preset choice.
  void onCustomPriceChanged(String _) => selectedPrice.value = null;

  void selectCapacity(int index) {
    selectedCapacity.value = selectedCapacity.value == index ? null : index;
    openPanel.value = null;
    loadHome();
  }

  /// "15 / 07 / 2024", or the placeholder when no date is picked.
  String get dateLabel {
    final date = selectedDate.value;
    if (date == null) return HomeStrings.datePlaceholder;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)} / ${two(date.month)} / ${date.year}';
  }

  String get priceLabel {
    final index = selectedPrice.value;
    return index == null ? HomeStrings.priceRange : HomeStrings.priceOptions[index];
  }

  /// View all fresh-up rooms.
  void openAllFresh() => Get.toNamed(
        Routes.SEARCH,
        arguments: const SearchArgs(
          type: 'stay',
          sort: 'newest',
          title: HomeStrings.freshUpRooms,
        ),
      );

  void onTabSelected(int index) {
    if (index == currentTab.value) return;
    closePanel();
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
}
