/// Strings for the partner Quick Updates screen (Page 03 / 3.1).
/// Shared partner styling lives in `lib/app/widgets/partner/partner_theme.dart`.
abstract final class QuickUpdatesStrings {
  static const pricesAndDiscount = 'Prices & Discount';
  static const slotAllocation = 'Slot Allocation';
  static const emptyMessage = 'Currently no activities available';

  /// Shown until `GET /api/partners/me` returns real data.
  static const placeholderName = 'Akhil';
}
