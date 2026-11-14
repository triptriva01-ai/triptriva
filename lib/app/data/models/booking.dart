import '../constants/api_endpoints.dart';
import 'listing_detail.dart';

/// Lifecycle of a reservation (Reservations page, FR-01).
enum BookingStatus { booked, completed }

/// A reservation shown on the "My Bookings" list.
class Booking {
  const Booking({
    required this.id,
    required this.bookingId,
    required this.title,
    this.imageUrl = '',
    this.people = 0,
    this.date = '',
    this.timeSlot = '',
    this.groupLabel = '',
    this.status = BookingStatus.booked,
    this.rawStatus = '',
    this.listingId = '',
  });

  /// Reads the API's `BookingSummaryResponse` (`listingTitle`, `coverImage`,
  /// ISO `date`, `slotStartTime`/`slotEndTime`) and the older shape alike.
  factory Booking.fromJson(Map<String, dynamic> json) {
    final when = DateTime.tryParse('${json['date'] ?? ''}');
    final slot = ListingSlot.formatRange(
      json['slotStartTime'] as String?,
      json['slotEndTime'] as String?,
    );
    final id = '${json['id'] ?? ''}';
    return Booking(
      id: id,
      bookingId: '${json['bookingId'] ?? _shortId(id)}',
      title: '${json['title'] ?? json['listingTitle'] ?? ''}',
      imageUrl: ApiConfig.mediaUrl(
        '${json['imageUrl'] ?? json['coverImage'] ?? json['image'] ?? ''}',
      ),
      people: _toInt(json['people'] ?? json['pax']) ?? 0,
      date: when == null ? '${json['date'] ?? ''}' : _dayMonth(when),
      timeSlot: '${json['timeSlot'] ?? json['slot'] ?? slot}',
      groupLabel: '${json['groupLabel'] ?? (when == null ? '' : _monthDay(when))}',
      status: _toStatus(json['status']),
      rawStatus: '${json['status'] ?? ''}',
      listingId: '${json['listingId'] ?? ''}',
    );
  }

  final String id;
  final String bookingId;
  final String title;
  final String imageUrl;
  final int people;
  final String date;
  final String timeSlot;
  final String groupLabel;
  final BookingStatus status;

  /// The API's own status: pending_payment, confirmed, completed,
  /// cancelled, expired.
  final String rawStatus;
  final String listingId;

  bool get isCompleted => status == BookingStatus.completed;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "11 Mar".
  static String _dayMonth(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';

  /// "Mar 15" — the date header the list groups by.
  static String _monthDay(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}';

  /// Mongo ids are 24 hex characters; the last 8 read better on a card.
  static String _shortId(String id) =>
      id.length > 8 ? id.substring(id.length - 8).toUpperCase() : id;

  static BookingStatus _toStatus(dynamic value) {
    final status = '$value'.toLowerCase();
    return status == 'completed' || status == 'cancelled' || status == 'expired'
        ? BookingStatus.completed
        : BookingStatus.booked;
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// Bookings sharing a date header on the list.
class BookingGroup {
  const BookingGroup({required this.label, required this.bookings});

  final String label;
  final List<Booking> bookings;
}
