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
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: '${json['id'] ?? ''}',
      bookingId: '${json['bookingId'] ?? json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? json['image'] ?? ''}',
      people: _toInt(json['people'] ?? json['pax']) ?? 0,
      date: '${json['date'] ?? ''}',
      timeSlot: '${json['timeSlot'] ?? json['slot'] ?? ''}',
      groupLabel: '${json['groupLabel'] ?? json['date'] ?? ''}',
      status: _toStatus(json['status']),
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

  bool get isCompleted => status == BookingStatus.completed;

  static BookingStatus _toStatus(dynamic value) {
    return '$value'.toLowerCase() == 'completed'
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
