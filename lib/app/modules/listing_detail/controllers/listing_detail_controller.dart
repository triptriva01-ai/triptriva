import 'package:get/get.dart';

import '../../../data/models/listing.dart';
import '../../../data/models/listing_detail.dart';
import '../../../data/providers/api_exception.dart';
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
      final data = await _propertyService.getDetail(listingId);
      if (data is Map<String, dynamic>) {
        detail.value = ListingDetail.fromJson(data);
      }
    } on ApiException catch (error) {
      Get.log('Listing detail load failed: $error');
      _loadSampleDetail();
      // Only complain if there is nothing at all to show.
      if (detail.value == null) {
        errorMessage.value = error.message;
      }
    } finally {
      isLoading.value = false;
    }
  }

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

  void selectReviewFilter(ReviewFilter filter) =>
      reviewFilter.value = filter;

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

  // ---------------------------------------------------------------------
  // Development placeholder — remove once `GET /api/properties/{id}` serves
  // real data.
  // ---------------------------------------------------------------------

  void _loadSampleDetail() {
    final existing = detail.value;

    detail.value = ListingDetail(
      id: existing?.id ?? listingId,
      name: existing?.name ?? 'Thrissur Tree House',
      address: 'Palarivattam , Kochi , Kerala',
      imageUrls: existing?.imageUrls ?? const [],
      rooms: 3,
      bathrooms: 3,
      beds: 6,
      rating: 4.5,
      ratingLabel: 'Great',
      ratingCaption: 'For the user',
      reviewCount: 5,
      host: const ListingHost(name: 'Raju MNK'),
      facilities: const ['Free wifi', 'Musical dramas', 'DJ', '3 rooms'],
      policies: const [
        'Cancellation is allowed before 10 days before the slot date',
        'Guests are not allowed',
        'Outside food is not allowed',
        '3 rooms',
      ],
      coordinates: '9.9948565, 76.3201928',
      about: 'A houseboat is a unique type of accommodation designed to offer '
          'the comfort of a home while floating on water. Traditionally used '
          'for transportation and living, houseboats today are popular for '
          'leisure travel and relaxing vacations, especially in scenic '
          'backwater destinations.',
      reviews: const [
        ListingReview(
          id: '1',
          authorName: 'Raju MNK',
          rating: 4.5,
          comment: 'This houseboat is a unique type of accommodation designed '
              'to offer the comfort of a home while floating on water.',
        ),
        ListingReview(
          id: '2',
          authorName: 'Raju MNK',
          rating: 4.5,
          comment: 'This houseboat is a unique type of accommodation designed '
              'to offer the comfort of a home while floating on water.',
        ),
      ],
      nearbyTitle: 'Near By Tree House',
      nearby: const [
        Listing(
          id: '101',
          title: 'Tree House',
          location: 'Palarivattam',
          rating: 4.5,
          price: 500,
          originalPrice: 1200,
          discountPercent: 14,
        ),
        Listing(
          id: '102',
          title: 'Tree House',
          location: 'Palarivattam',
          rating: 4.5,
          price: 500,
          originalPrice: 1200,
          discountPercent: 14,
        ),
        Listing(
          id: '103',
          title: 'Tree House',
          location: 'Palarivattam',
          rating: 4.5,
          price: 500,
          originalPrice: 1200,
          discountPercent: 14,
        ),
      ],
      slots: const [
        ListingSlot(
          id: 'day',
          name: 'Day Trip',
          timeRange: '11 AM - 05 PM',
          price: 500,
          originalPrice: 1200,
        ),
        ListingSlot(
          id: 'overnight',
          name: 'Overnight',
          timeRange: '12 PM - 09 AM',
          price: 900,
          originalPrice: 1600,
        ),
        ListingSlot(
          id: 'night',
          name: 'Night Stay',
          timeRange: '5:30 PM - 09 AM',
          price: 1200,
          originalPrice: 2000,
        ),
      ],
      price: 500,
      originalPrice: 1200,
      cancellationNote: 'Free cancellation before 24 hours',
      refreshingRoomNote: 'Get 1 hour for refreshing',
    );
  }
}
