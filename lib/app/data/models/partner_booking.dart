/// A paid booking on one of the signed-in partner's listings, as returned by
/// `GET /api/partners/me/bookings`.
class PartnerBooking {
  const PartnerBooking({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.guestName,
    required this.date,
    this.slotStartTime,
    this.slotEndTime,
    this.pax = 0,
    this.status = '',
    this.amount = 0,
    this.listingType = '',
    this.checkedInAt,
  });

  factory PartnerBooking.fromJson(Map<String, dynamic> json) {
    return PartnerBooking(
      id: '${json['id'] ?? ''}',
      listingId: '${json['listingId'] ?? ''}',
      listingTitle: '${json['listingTitle'] ?? ''}',
      guestName: '${json['guestName'] ?? ''}',
      date: _calendarDate(json['date']),
      slotStartTime: json['slotStartTime'] as String?,
      slotEndTime: json['slotEndTime'] as String?,
      pax: (json['pax'] as num?)?.toInt() ?? 0,
      status: '${json['status'] ?? ''}'.toLowerCase(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      checkedInAt: DateTime.tryParse('${json['checkedInAt'] ?? ''}')?.toLocal(),
    );
  }

  final String id;
  final String listingId;
  final String listingTitle;
  final String guestName;
  final DateTime date;
  final String? slotStartTime;
  final String? slotEndTime;
  final int pax;

  /// "confirmed", "completed", "cancelled" …
  final String status;
  final double amount;

  /// Not part of the booking response — filled from the partner's listings so
  /// the dashboard's category chips can filter.
  final String listingType;

  /// When the partner checked the guest in at the venue; null until then.
  final DateTime? checkedInAt;

  bool get isCheckedIn => checkedInAt != null;

  /// Completed, or confirmed with the date already passed — the same rule as
  /// the backend's "completed" filter.
  bool get isCompleted {
    if (status == 'completed') return true;
    final now = DateTime.now();
    return status == 'confirmed' &&
        date.isBefore(DateTime(now.year, now.month, now.day));
  }
  bool get isCancelled => status == 'cancelled';

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// "10:00 - 16:00", or empty for a whole-day booking.
  String get slotLabel => slotStartTime == null || slotStartTime!.isEmpty
      ? ''
      : '$slotStartTime - ${slotEndTime ?? ''}';

  String get dateLabel => '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// Short reference a guest can read out — the tail of the booking id.
  String get shortRef =>
      id.length <= 6 ? id.toUpperCase() : id.substring(id.length - 6).toUpperCase();

  PartnerBooking withListingType(String type) => PartnerBooking(
        id: id,
        listingId: listingId,
        listingTitle: listingTitle,
        guestName: guestName,
        date: date,
        slotStartTime: slotStartTime,
        slotEndTime: slotEndTime,
        pax: pax,
        status: status,
        amount: amount,
        listingType: type,
        checkedInAt: checkedInAt,
      );

  /// The backend sends the booked day as midnight UTC. Keep that calendar
  /// date as-is: converting to local time would move it a day west of UTC.
  static DateTime _calendarDate(dynamic value) {
    final parsed = DateTime.tryParse('$value');
    if (parsed == null) return DateTime.now();
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
