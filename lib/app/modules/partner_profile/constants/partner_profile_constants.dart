/// Strings for the partner profile screen (Sheet2 Page 06).
/// Shared styling lives in `lib/app/widgets/profile/profile_theme.dart`.
abstract final class PartnerProfileStrings {
  static const title = 'Profile';
  static const backToLead = 'Back to ';
  static const brandLight = 'trip';
  static const brandBold = 'triva';
  static const accountsSection = 'Accounts & Personal';
  static const paymentMethod = 'Payment Method';
  static const language = 'Language';
  static const feedback = 'Feedback';
  static const dataPrivacy = 'Data Control & Privacy';
  static const customerSupport = 'Customer support';
  static const about = 'About';
  static const logout = 'Log Out';

  /// Shown until `GET /api/partners/me` returns real data.
  static const placeholderName = 'Fahad';
  static const placeholderPhone = '8795647558';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class PartnerProfileDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class PartnerProfileSizes {
  static const headerTopSpacing = 10.0;
  static const backIconSize = 22.0;
  static const backIconToTitle = 16.0;
  static const headerToCard = 16.0;
  static const cardToBand = 16.0;
}
