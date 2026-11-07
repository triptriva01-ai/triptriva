/// Central registry of every backend endpoint used by the TripTrivia app.
///
/// Paths are sourced from `Backend_APIs.xlsx`. Parameterised routes (those that
/// contain an `{id}`) are exposed as functions so call-sites stay type-safe and
/// there is a single place to change a path if the contract moves.
///
/// Grouping mirrors the spreadsheet sheets so each module maps 1:1 to a
/// service in `lib/app/data/services/`.
abstract final class ApiConfig {
  /// Host running the Triptriva.API server, as reachable **from the device
  /// the app is running on**.
  ///
  /// `'localhost'` works on a USB-connected phone because of the adb reverse
  /// tunnel, which forwards the phone's own port 5080 to the laptop:
  ///
  /// ```
  /// adb reverse tcp:5080 tcp:5080
  /// ```
  ///
  /// That is the most reliable option: it survives the laptop's IP changing
  /// and needs no Windows Firewall exception. Re-run it after replugging the
  /// device or restarting adb.
  ///
  /// Alternatives:
  ///  * `'10.0.2.2'` — Android emulator's alias for the host machine
  ///  * the laptop's LAN IP — physical device on the **same** Wi-Fi, and only
  ///    if the firewall allows inbound 5080
  static const String host = 'localhost';

  /// Matches the `http` launch profile in `Triptriva.API/Properties/
  /// launchSettings.json`.
  static const int port = 5080;

  /// The API serves plain HTTP in development, so Android needs
  /// `usesCleartextTraffic` (already set in AndroidManifest.xml).
  static String get baseUrl => 'http://$host:$port';

  /// Common prefix shared by every route below.
  static const String apiPrefix = '/api';

  static const Duration connectTimeout = Duration(seconds: 20);

  /// Uploads stored on the API server come back as paths ("/media/…");
  /// images need a full URL. Absolute URLs (an S3/R2 bucket) pass through.
  static String mediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.startsWith('/') ? '$baseUrl$url' : url;
  }
}

/// The only endpoints the .NET backend implements today (`UsersController`).
/// Everything below this class is still specification-only — see the note on
/// [AuthEndpoints].
abstract final class UsersEndpoints {
  /// GET (page, limit, role) and POST.
  static const String users = '/api/users';

  /// GET, PUT (partial) and DELETE.
  static String detail(String id) => '/api/users/$id';
}

/// Authentication & session management — implemented by `AuthController`.
abstract final class AuthEndpoints {
  static const String register = '/api/auth/register';

  /// Body: `{identifier, password}` — identifier is an email OR a phone.
  static const String login = '/api/auth/login';

  /// Exchange a Google/Apple ID token for our own session.
  /// Body: `{provider, idToken, name?}`.
  static const String social = '/api/auth/social';

  /// Body: `{refreshToken}`.
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String deviceToken = '/api/auth/device-token';

  /// Sends a one-time code. Body: `{identifier}`.
  static const String otpRequest = '/api/auth/otp/request';

  /// Exchanges a code for a session, creating the account if it is new.
  /// Body: `{identifier, code, name?}`.
  static const String otpVerify = '/api/auth/otp/verify';

  /// The signed-in user, resolved from the bearer token.
  static const String me = '/api/auth/me';

  /// Texts a code to a number the signed-in user is adding. Body: `{phone}`.
  static const String phoneOtp = '/api/auth/phone/otp';

  /// Saves the number once the code checks out. Body: `{phone, code}`.
  static const String phoneVerify = '/api/auth/phone/verify';
}

/// Home / Explore page — `Home` sheet (Page 1).
abstract final class HomeEndpoints {
  static const String listings = '/api/listings';
  static const String popular = '/api/listings/popular';
  static const String nearby = '/api/listings/nearby';
  static const String fresh = '/api/listings/fresh';
  static const String freshAll = '/api/listings/fresh/all';
  static const String newAdventures = '/api/listings/new-adventures';
  static const String banners = '/api/banners';
  static const String categories = '/api/listings/categories';
}

/// Search & discovery page — `Search` sheet (Page 6).
abstract final class SearchEndpoints {
  static const String search = '/api/search';
  static const String suggestions = '/api/search/suggestions';
  static const String nearby = '/api/search/nearby';
  static const String available = '/api/search/available';
  static const String popularLocations = '/api/search/popular-locations';
  static const String recent = '/api/search/recent';

  static String recentEntry(String id) => '/api/search/recent/$id';
}

/// Property details page — `Property` sheet (Page 5).
abstract final class PropertyEndpoints {
  static String detail(String id) => '/api/listings/$id';
  static String reviews(String id) => '/api/listings/$id/reviews';
  static String nearby(String id) => '/api/listings/$id/nearby';
}

/// Date & slot booking page — `Slot Booking` sheet (Page 6).
abstract final class SlotEndpoints {
  static String availability(String listingId) =>
      '/api/listings/$listingId/availability';
  static String slots(String listingId) => '/api/listings/$listingId/slots';

  static const String freeze = '/api/slots/freeze';

  static String freezeStatus(String freezeId) => '/api/slots/freeze/$freezeId';
}

/// PAX selection & pricing page — `PAX & Pricing` sheet (Page 7).
abstract final class PricingEndpoints {
  static String pricing(String listingId) => '/api/listings/$listingId/pricing';
  static const String validateCoupon = '/api/coupons/validate';
  static const String coupons = '/api/coupons';
  static const String initiateBooking = '/api/bookings/initiate';
}

/// Reservations page — `Reservations` sheet (Page 2).
abstract final class BookingEndpoints {
  static const String bookings = '/api/bookings';

  static String detail(String id) => '/api/bookings/$id';
  static String cancel(String id) => '/api/bookings/$id/cancel';
  static String invoice(String id) => '/api/bookings/$id/invoice';
  static String payment(String id) => '/api/bookings/$id/payment';
}

/// Wishlist page — `Wishlist` sheet (Page 3).
abstract final class WishlistEndpoints {
  static const String wishlist = '/api/wishlist';

  static String item(String listingId) => '/api/wishlist/$listingId';
  static String check(String listingId) => '/api/wishlist/check/$listingId';
}

/// Profile page — `Profile` sheet (Page 4).
abstract final class ProfileEndpoints {
  static const String profile = '/api/users/profile';
  static const String profileImage = '/api/users/profile/image';
  static const String paymentMethods = '/api/users/payment-methods';
  static const String feedback = '/api/users/feedback';
  static const String language = '/api/users/language';
  static const String partnerRegister = '/api/partners/register';

  static String paymentMethod(String id) => '/api/users/payment-methods/$id';
}

/// Notifications page — `Notifications` sheet (Page 8).
abstract final class NotificationEndpoints {
  static const String notifications = '/api/notifications';
  static const String readAll = '/api/notifications/read-all';
  static const String unreadCount = '/api/notifications/unread-count';

  static String read(String id) => '/api/notifications/$id/read';
  static String delete(String id) => '/api/notifications/$id';
}

/// Reviews — `Reviews` sheet (cross-screen).
abstract final class ReviewEndpoints {
  static const String reviews = '/api/reviews';

  static String forListing(String listingId) => '/api/reviews/$listingId';
}

/// File / media upload — `Media` sheet (cross-screen).
abstract final class MediaEndpoints {
  static const String upload = '/api/media/upload';
}

/// Admin — revenue dashboard — `Admin Revenue` sheet (Page 1).
abstract final class AdminRevenueEndpoints {
  static const String summary = '/api/admin/revenue/summary';
  static const String growthCurve = '/api/admin/revenue/growth-curve';
  static const String categories = '/api/admin/revenue/categories';
  static const String bookings = '/api/admin/revenue/bookings';
}

/// Admin — activities management — `Admin Activities` sheet (Page 2).
abstract final class AdminActivityEndpoints {
  static const String activities = '/api/admin/activities';
  static const String analytics = '/api/admin/activities/analytics';

  static String detail(String id) => '/api/admin/activities/$id';
  static String accept(String id) => '/api/admin/activities/$id/accept';
  static String reject(String id) => '/api/admin/activities/$id/reject';
}

/// Admin — users management — `Admin Users` sheet (Page 3).
abstract final class AdminUserEndpoints {
  static const String users = '/api/admin/users';

  static String detail(String id) => '/api/admin/users/$id';
  static String status(String id) => '/api/admin/users/$id/status';
  static String delete(String id) => '/api/admin/users/$id';
}

/// Admin — profile & notifications — `Admin Profile` sheet (Page 4).
abstract final class AdminProfileEndpoints {
  static const String profile = '/api/admin/profile';
  static const String profileImage = '/api/admin/profile/image';
  static const String paymentMethods = '/api/admin/payment-methods';
  static const String language = '/api/admin/language';
  static const String notifications = '/api/admin/notifications';

  static String notificationRead(String id) =>
      '/api/admin/notifications/$id/read';
}

/// Partner portal — `PartnersController`.
/// Location search behind the maps — proxied by the backend so the Google
/// Places / Geocoding key never ships in the app. 503 when not configured.
abstract final class GeoEndpoints {
  /// Query: `q`, `session`, optional `lat`/`lng` to rank nearby matches first.
  static const String autocomplete = '/api/geo/autocomplete';

  /// Query: `lat`, `lng`.
  static const String reverse = '/api/geo/reverse';

  /// Query: `session` — the same token used while typing.
  static String place(String placeId) =>
      '/api/geo/places/${Uri.encodeComponent(placeId)}';
}

abstract final class PartnerEndpoints {
  static const String apply = '/api/partners/apply';
  static const String me = '/api/partners/me';
  static const String myListings = '/api/partners/me/listings';
  static const String myBookings = '/api/partners/me/bookings';
  static const String myRevenue = '/api/partners/me/revenue';

  /// Body: `{listingId, date, slotId?, pax?, guestName, guestPhone?}` — a
  /// walk-in, recorded as paid at the venue. Returns the booking with its
  /// check-in code.
  static const String manualBooking = '/api/partners/me/bookings/manual';

  static String myListing(String id) => '/api/partners/me/listings/$id';

  /// Body: `{code}` — the 6-digit code from the guest's booking.
  static String checkIn(String bookingId) =>
      '/api/partners/me/bookings/$bookingId/check-in';
  static String availability(String listingId) =>
      '/api/partners/me/listings/$listingId/availability';
}
