import '../constants/api_endpoints.dart';
import 'listing_detail.dart' show ListingSlot, ListingSlotNames;
import 'booking.dart';
import 'geo_place.dart';

/// One line on the bill breakdown.
///
/// Covers every row in the design: a plain charge, a discounted charge with
/// the original struck through, a deduction, and the green "You have saved".
class BillLine {
  const BillLine({
    required this.label,
    required this.amount,
    this.originalAmount,
    this.isDeduction = false,
    this.isSaving = false,
  });

  factory BillLine.fromJson(Map<String, dynamic> json) {
    return BillLine(
      label: '${json['label'] ?? ''}',
      amount: _toDouble(json['amount']) ?? 0,
      originalAmount: _toDouble(json['originalAmount']),
      isDeduction: json['isDeduction'] as bool? ?? false,
      isSaving: json['isSaving'] as bool? ?? false,
    );
  }

  final String label;
  final double amount;

  /// Pre-discount figure, struck through beside [amount] when present.
  final double? originalAmount;

  /// Rendered as "- ₹x", e.g. a coupon.
  final bool isDeduction;

  /// Rendered in green, e.g. "You have saved".
  final bool isSaving;

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Room/bed counts shown under "Stay Details". Absent for day activities.
class StayDetails {
  const StayDetails({this.rooms = 0, this.bathrooms = 0, this.beds = 0});

  factory StayDetails.fromJson(Map<String, dynamic> json) {
    return StayDetails(
      rooms: _toInt(json['rooms']) ?? 0,
      bathrooms: _toInt(json['bathrooms']) ?? 0,
      beds: _toInt(json['beds']) ?? 0,
    );
  }

  final int rooms;
  final int bathrooms;
  final int beds;

  bool get isEmpty => rooms == 0 && bathrooms == 0 && beds == 0;

  /// "3 rooms", "3 bathroom", "6 bed" — joined with dots by the view.
  List<String> get labels => [
        if (rooms > 0) '$rooms room${rooms == 1 ? '' : 's'}',
        if (bathrooms > 0) '$bathrooms bathroom',
        if (beds > 0) '$beds bed',
      ];

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// The "Go to page" card linking back to the listing that was booked.
class RelatedListing {
  const RelatedListing({
    required this.id,
    required this.name,
    this.address = '',
    this.imageUrl = '',
  });

  factory RelatedListing.fromJson(Map<String, dynamic> json) {
    return RelatedListing(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? json['title'] ?? ''}',
      address: '${json['address'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? json['image'] ?? ''}',
    );
  }

  final String id;
  final String name;
  final String address;
  final String imageUrl;
}

/// Everything the booking detail screen ("reservation inside") shows.
///
/// Deliberately a flat, complete payload: the design has no partial states, so
/// one `GET /api/bookings/{id}` fills the whole page and can be cached offline.
class BookingDetail {
  const BookingDetail({
    required this.id,
    required this.bookingId,
    required this.listingName,
    this.status = BookingStatus.booked,
    this.address = '',
    this.imageUrl = '',
    this.mapUrl = '',
    this.partnerName = '',
    this.partnerPhone = '',
    this.bookingDate = '',
    this.tripType = '',
    this.timeSlot = '',
    this.checkOutDate = '',
    this.checkOutTimeSlot = '',
    this.stay = const StayDetails(),
    this.facilities = const [],
    this.policies = const [],
    this.about = '',
    this.total = 0,
    this.charges = const [],
    this.billLines = const [],
    this.related,
    this.hasReview = false,
    this.checkInCode = '',
    this.point,
    this.rawStatus = '',
    this.listingId = '',
    this.canCancel = false,
    this.canDownloadInvoice = false,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    // The booking API nests the listing snapshot under `listing`.
    final listing = json['listing'] is Map
        ? (json['listing'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final listingAddress = [listing['address'], listing['city']]
        .where((part) => part is String && part.trim().isNotEmpty)
        .join(', ');
    final pricing = json['pricing'] is Map
        ? (json['pricing'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final payment = json['payment'] is Map
        ? (json['payment'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final when = DateTime.tryParse('${json['date'] ?? ''}');
    final start = (listing['slotStartTime'] ?? json['slotStartTime']) as String?;
    final end = (listing['slotEndTime'] ?? json['slotEndTime']) as String?;
    final rawStatus = '${json['status'] ?? ''}'.toLowerCase();

    double money(String key) => BillLine._toDouble(pricing[key]) ?? 0;
    final base = money('basePrice');
    final discounted = money('discountedPrice');
    final coupon = money('couponDiscount');
    final finalAmount = BillLine._toDouble(pricing['finalAmount']);
    final method = '${payment['method'] ?? ''}';

    // The API has no ready-made bill lines; build them from `pricing`.
    final apiBill = pricing.isEmpty
        ? const <BillLine>[]
        : [
            BillLine(
              label: 'Trip charge',
              amount: discounted,
              originalAmount: base > discounted ? base : null,
            ),
            if (base > discounted)
              BillLine(
                label: 'Listing discount',
                amount: base - discounted,
                isDeduction: true,
              ),
            if (coupon > 0)
              BillLine(
                label: 'Coupon ${pricing['couponCode'] ?? ''}'.trim(),
                amount: coupon,
                isDeduction: true,
              ),
            if (base - (finalAmount ?? discounted) > 0)
              BillLine(
                label: 'You have saved',
                amount: base - (finalAmount ?? discounted),
                isSaving: true,
              ),
          ];

    return BookingDetail(
      id: '${json['id'] ?? ''}',
      bookingId: '${json['bookingId'] ?? _shortId('${json['id'] ?? ''}')}',
      listingName:
          '${json['listingName'] ?? json['title'] ?? listing['title'] ?? ''}',
      status: rawStatus == 'completed' ||
              rawStatus == 'cancelled' ||
              rawStatus == 'expired'
          ? BookingStatus.completed
          : BookingStatus.booked,
      rawStatus: rawStatus,
      address: json['address'] is String
          ? json['address'] as String
          : listingAddress,
      imageUrl: ApiConfig.mediaUrl(
        '${json['imageUrl'] ?? json['image'] ?? listing['coverImage'] ?? ''}',
      ),
      mapUrl: '${json['mapUrl'] ?? ''}',
      partnerName: '${json['partnerName'] ?? ''}',
      partnerPhone: '${json['partnerPhone'] ?? ''}',
      bookingDate: '${json['bookingDate'] ?? (when == null ? '' : _longDate(when))}',
      tripType: '${json['tripType'] ?? (start == null ? _typeLabel('${listing['type'] ?? ''}') : ListingSlotNames.forTimes(start, end))}',
      timeSlot: '${json['timeSlot'] ?? (start == null ? (listing['checkInTime'] == null ? '' : 'Check-in ${listing['checkInTime']}') : ListingSlot.formatRange(start, end))}',
      checkOutDate: '${json['checkOutDate'] ?? ''}',
      checkOutTimeSlot: '${json['checkOutTimeSlot'] ?? (listing['checkOutTime'] == null ? '' : 'Check-out ${listing['checkOutTime']}')}',
      stay: json['stay'] is Map<String, dynamic>
          ? StayDetails.fromJson(json['stay'] as Map<String, dynamic>)
          : const StayDetails(),
      facilities: _toStringList(json['facilities']),
      policies: [
        ..._toStringList(json['policies']),
        if (listing['cancellationPolicy'] != null)
          'Cancellation: ${listing['cancellationPolicy']}',
      ],
      about: '${json['about'] ?? ''}',
      total: BillLine._toDouble(json['total']) ?? finalAmount ?? 0,
      charges: json['charges'] is List
          ? _toLines(json['charges'])
          : [
              if (pricing.isNotEmpty)
                BillLine(label: 'Trip charge', amount: discounted),
              if (method.isNotEmpty)
                BillLine(
                  label: 'Paid by ${method.toUpperCase()}',
                  amount: BillLine._toDouble(payment['amountPaid']) ?? 0,
                ),
            ],
      billLines: json['billLines'] is List ? _toLines(json['billLines']) : apiBill,
      listingId: '${json['listingId'] ?? ''}',
      canCancel: json['canCancel'] == true,
      canDownloadInvoice: json['canDownloadInvoice'] == true,
      related: json['related'] is Map<String, dynamic>
          ? RelatedListing.fromJson(json['related'] as Map<String, dynamic>)
          : '${json['listingId'] ?? ''}'.isEmpty
              ? null
              : RelatedListing(
                  id: '${json['listingId']}',
                  name: '${listing['title'] ?? ''}',
                  address: listingAddress,
                  imageUrl: ApiConfig.mediaUrl('${listing['coverImage'] ?? ''}'),
                ),
      hasReview: json['hasReview'] as bool? ?? false,
      checkInCode: '${json['checkInCode'] ?? ''}',
      point: GeoPoint.tryParse(
        json['latitude'] ?? listing['latitude'],
        json['longitude'] ?? listing['longitude'],
      ),
    );
  }

  final String id;
  final String bookingId;
  final String listingName;
  final BookingStatus status;
  final String address;
  final String imageUrl;

  /// Deep link opened by "Get Direction".
  final String mapUrl;

  final String partnerName;
  final String partnerPhone;

  final String bookingDate;

  /// "Day Trip", "Overnight" — shown beside the slot.
  final String tripType;
  final String timeSlot;

  /// Second date/slot for multi-day stays; empty for a day activity.
  final String checkOutDate;
  final String checkOutTimeSlot;

  final StayDetails stay;
  final List<String> facilities;
  final List<String> policies;
  final String about;

  /// Headline figure on the Total Price card.
  final double total;

  /// Summary lines on the Total Price card ("Day Trip Charge", "Google pay").
  final List<BillLine> charges;

  /// Full breakdown behind "Payment Details".
  final List<BillLine> billLines;

  final RelatedListing? related;

  /// True once the traveller has left a review, hiding the review prompt.
  final bool hasReview;

  /// The 6-digit code the guest reads out to the partner at check-in. Empty
  /// once checked in, or for a cancelled or past trip.
  final String checkInCode;

  /// The listing's map point, for directions; null for older bookings (then
  /// directions use [address]).
  final GeoPoint? point;

  /// The API's status: pending_payment, confirmed, completed, cancelled,
  /// expired.
  final String rawStatus;
  final String listingId;
  final bool canCancel;
  final bool canDownloadInvoice;

  bool get isCancelled => rawStatus == 'cancelled';

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// "12 November 2026".
  static String _longDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static String _shortId(String id) =>
      id.length > 8 ? id.substring(id.length - 8).toUpperCase() : id;

  static String _typeLabel(String type) => switch (type) {
        'houseboat' => 'House Boat',
        'adventure' => 'Adventure',
        'stay' => 'Stay',
        _ => '',
      };

  bool get isCompleted => status == BookingStatus.completed;

  /// A completed trip with no review yet gets the "Write a Review" prompt.
  bool get canReview => isCompleted && !hasReview;

  /// Only upcoming trips can have a reminder set.
  bool get canRemind => !isCompleted;

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => '$item').where((item) => item.isNotEmpty).toList();
  }

  static List<BillLine> _toLines(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(BillLine.fromJson)
        .toList();
  }
}
