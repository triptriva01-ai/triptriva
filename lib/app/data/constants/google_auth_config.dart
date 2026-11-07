/// OAuth **client IDs** from Google Cloud Console → APIs & Services →
/// Credentials.
///
/// Client IDs are not secrets — they ship inside the app and are safe to
/// commit. Security comes from the backend verifying the ID token against
/// [serverClientId].
///
/// NEVER put a client **secret** (the value starting with `GOCSPX-`) in this
/// file, or anywhere else in the app. Mobile apps cannot keep secrets.
abstract final class GoogleAuthConfig {
  /// The **Web application** OAuth client ID.
  ///
  /// Despite the name, this is what Android sends as `serverClientId`, and it
  /// is the audience the backend checks when verifying the ID token.
  ///
  /// TODO(setup): paste the Web client ID between the quotes. It must look
  /// like '1234567890-abcdefg.apps.googleusercontent.com'.
  static const serverClientId = '737609790235-h1i7t4ogpaouiij5dren4b8sksnl7sag.apps.googleusercontent.com';

  /// The **iOS** OAuth client ID. Only needed for iOS builds.
  ///
  /// TODO(setup): paste the iOS client ID here when building for iPhone.
  static const iosClientId = '';

  /// Guard so the UI can explain the problem instead of crashing when the
  /// client IDs have not been filled in yet.
  static bool get isConfigured => serverClientId.isNotEmpty;
}
