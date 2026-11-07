/// Strings for the traveller profile screen.
/// Shared styling lives in `lib/app/widgets/profile/profile_theme.dart`.
abstract final class ProfileStrings {
  static const title = 'Profile';
  static const wishlist = 'Wishlist';
  static const adminPanel = 'Admin Panel';
  static const editProfile = 'Edit Profile';
  static const partnerLead = 'Become ';
  static const partnerBrandLight = 'trip';
  static const partnerBrandBold = 'triva';
  static const partnerTrail = ' partner';
  static const accountsSection = 'Accounts & Personal';
  static const paymentMethod = 'Payment Method';
  static const language = 'Language';
  static const feedback = 'Feedback';
  static const dataPrivacy = 'Data Control & Privacy';
  static const logout = 'Log Out';

  static const navExplore = 'Explore';
  static const navReservations = 'Reservations';
  static const navWishlist = 'Wishlist';
  static const navProfile = 'Profile';

  /// Shown until `GET /api/users/profile` returns real data.
  static const placeholderName = 'Fahad';
  static const placeholderPhone = '8795647558';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class ProfileDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class ProfileHeaderSizes {
  static const bellSize = 49.0;
  static const bellIconSize = 20.0;
  static const headerToCard = 10.0;
  static const cardToActions = 16.0;
  static const quickActionHeight = 68.0;
  static const quickActionGap = 16.0;
}
