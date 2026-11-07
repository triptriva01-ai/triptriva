/// Strings specific to the partner reservation dashboard.
/// Shared partner styling lives in `lib/app/widgets/partner/partner_theme.dart`.
abstract final class PartnerStrings {
  static const todayBookings = "Today's Bookings";
  static const allBookings = 'All Bookings';
  static const emptyMessage = 'Currently no activities available';
  static const addManualSlot = 'Add Manual Slot';

  /// Shown until `GET /api/partners/me` returns real data.
  static const placeholderName = 'Akhil';
}
