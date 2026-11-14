import 'package:get/get.dart';

import '../../../data/models/admin_models.dart';
import '../../../data/models/listing.dart';
import '../../../data/models/listing_detail.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/admin_service.dart';
import '../../../data/services/property_service.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../routes/app_pages.dart';
import '../constants/listing_detail_constants.dart';
import '../../../data/services/geo_service.dart';

/// How the review list is sorted / narrowed.
enum ReviewFilter { all, recent, positive, negative, old }

/// Listing detail — the product page reached from Home, Wishlist and the
/// "Near By" rails.
class ListingDetailController extends GetxController {
  final PropertyService _propertyService = Get.find<PropertyService>();
  final WishlistService _wishlistService = Get.find<WishlistService>();

  final detail = Rxn<ListingDetail>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Index of the hero photo currently showing.
  final currentImage = 0.obs;

  final isAboutExpanded = false.obs;
  final isWishlisted = false.obs;
  final reviewFilter = ReviewFilter.all.obs;

  /// The id being shown, from route arguments.
  String listingId = '';

  /// Opened from the admin activities list, for a possibly unpublished
  /// listing: no nearby rail, wishlist or review paging.
  bool _isAdminReview = false;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Listing) {
      listingId = args.id;
      isWishlisted.value = args.isWishlisted;
      // Render immediately from the card the traveller tapped, then fill in
      // the rest.
      detail.value = _fromCard(args);
    } else if (args is AdminActivitySubmission) {
      // Admin review: a submission's id is its listing's id.
      _isAdminReview = true;
      listingId = args.id;
      detail.value = ListingDetail(id: args.id, name: args.name);
    } else if (args is Map) {
      listingId = '${args['id'] ?? ''}';
    } else if (args is String) {
      listingId = args;
    }

    if (listingId.isNotEmpty) {
      loadDetail();
    }
  }

  /// Placeholder built from the data the card already had, so the page never
  /// opens blank while the request is in flight.
  ListingDetail _fromCard(Listing listing) {
    return ListingDetail(
      id: listing.id,
      name: listing.title,
      address: listing.location,
      imageUrls: [if (listing.imageUrl.isNotEmpty) listing.imageUrl],
      rating: listing.rating,
      price: listing.price,
      originalPrice: listing.originalPrice,
    );
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (_isAdminReview) {
        final data = await Get.find<AdminService>().getActivity(listingId);
        final listing = data is Map ? data['listing'] : null;
        if (listing is Map<String, dynamic>) {
          detail.value = ListingDetail.fromJson(listing);
        }
        return;
      }
      final data = await _propertyService.getDetail(listingId);
      if (data is Map<String, dynamic>) {
        detail.value = ListingDetail.fromJson(data);
      }
    } on ApiException catch (error) {
      Get.log('Listing detail load failed: $error');
      // Keep whatever the card already showed; only complain if there is
      // nothing at all.
      if (detail.value == null) {
        errorMessage.value = error.message;
      }
      return;
    } finally {
      isLoading.value = false;
    }
    await Future.wait([_loadNearby(), _loadWishlisted(), _loadReviews()]);
  }

  /// "Near By" rail — a separate endpoint, nearest first.
  Future<void> _loadNearby() async {
    try {
      final data = await _propertyService.getNearby(listingId);
      final current = detail.value;
      if (data is! List || current == null) return;
      detail.value = current.copyWith(
        nearbyTitle: _nearbyTitle(current.type),
        nearby: data
            .whereType<Map<String, dynamic>>()
            .map(Listing.fromJson)
            .where((item) => item.id != listingId)
            .toList(),
      );
    } on ApiException catch (error) {
      Get.log('Nearby listings load failed: $error');
    }
  }

  static String _nearbyTitle(String type) => switch (type) {
        'houseboat' => 'Near By House Boats',
        'adventure' => 'Near By Adventures',
        _ => 'Near By Stays',
      };

  Future<void> _loadWishlisted() async {
    try {
      final data = await _wishlistService.isWishlisted(listingId);
      if (data is Map) {
        isWishlisted.value = data['isWishlisted'] == true ||
            data['inWishlist'] == true ||
            data['exists'] == true;
      }
    } on ApiException catch (error) {
      Get.log('Wishlist check failed: $error');
    }
  }

  /// The detail payload carries only the newest few reviews; fetch a full
  /// page for the filter chips.
  Future<void> _loadReviews() async {
    try {
      final data = await _propertyService.getReviews(
        listingId,
        query: {'filter': _apiFilter(reviewFilter.value), 'limit': 20},
      );
      final current = detail.value;
      if (data is! Map || current == null) return;
      final page = data['reviews'];
      final items = page is Map ? page['items'] : page;
      if (items is! List) return;
      final summary = data['summary'];
      detail.value = current.copyWith(
        reviews: items
            .whereType<Map<String, dynamic>>()
            .map(ListingReview.fromJson)
            .toList(),
        reviewCount: summary is Map && summary['count'] is num
            ? (summary['count'] as num).toInt()
            : null,
      );
    } on ApiException catch (error) {
      Get.log('Reviews load failed: $error');
    }
  }

  static String _apiFilter(ReviewFilter filter) => switch (filter) {
        ReviewFilter.recent => 'recent',
        ReviewFilter.positive => 'positive',
        ReviewFilter.negative => 'negative',
        _ => 'all',
      };

  /// Reviews matching the current filter.
  ///
  /// Read this inside an `Obx` builder — the observable reads happen here, so
  /// calling it from the builder body is what registers them.
  List<ListingReview> get visibleReviews {
    final filter = reviewFilter.value;
    final all = detail.value?.reviews.toList() ?? const <ListingReview>[];

    return switch (filter) {
      ReviewFilter.all => all,
      ReviewFilter.recent => all,
      ReviewFilter.positive =>
        all.where((review) => review.rating >= 4).toList(),
      ReviewFilter.negative =>
        all.where((review) => review.rating < 3).toList(),
      // The backend returns newest first, so "Old" is that order reversed.
      ReviewFilter.old => all.reversed.toList(),
    };
  }

  void selectReviewFilter(ReviewFilter filter) {
    if (reviewFilter.value == filter) return;
    reviewFilter.value = filter;
    if (listingId.isNotEmpty) _loadReviews();
  }

  void selectImage(int index) => currentImage.value = index;

  void toggleAbout() => isAboutExpanded.toggle();

  void goBack() => Get.back();

  /// Saves or unsaves the listing, rolling back if the request fails so the
  /// heart never lies about what the server has.
  Future<void> toggleWishlist() async {
    final nowWishlisted = !isWishlisted.value;
    isWishlisted.value = nowWishlisted;
    try {
      if (nowWishlisted) {
        await _wishlistService.add(listingId);
      } else {
        await _wishlistService.remove(listingId);
      }
    } on ApiException catch (error) {
      Get.log('Wishlist toggle failed: $error');
      isWishlisted.value = !nowWishlisted;
    }
  }

  /// Opens the booking flow for this listing.
  void checkSlotAvailability() {
    final listing = detail.value;
    if (listing == null) return;
    Get.toNamed(Routes.BOOKING, arguments: listing);
  }

  void openNearby(Listing listing) =>
      Get.toNamed(Routes.LISTING_DETAIL, arguments: listing);

  /// Opens the listing in Google Maps — by its point, else by its address.
  Future<void> openMap() async {
    final current = detail.value;
    if (current == null) return;
    final opened = await GeoService.openInMaps(
      point: current.point,
      address: current.address,
    );
    if (!opened) _pending('Maps');
  }

  void share() => _pending('Sharing');

  void _pending(String feature) {
    Get.snackbar(
      ListingDetailStrings.pendingTitle,
      ListingDetailStrings.pendingMessage(feature),
      duration: ListingDetailDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
