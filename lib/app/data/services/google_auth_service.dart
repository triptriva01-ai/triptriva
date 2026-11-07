import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/google_auth_config.dart';

/// Raised when the Google SDK reports a failure, carrying the provider's own
/// error code so the cause is visible instead of being flattened into a
/// generic message.
class GoogleAuthException implements Exception {
  const GoogleAuthException(this.code, [this.description]);

  final String code;
  final String? description;

  @override
  String toString() => 'GoogleAuthException($code): $description';
}

/// Thin wrapper around the Google Sign-In SDK.
///
/// Its only job is to return a Google **ID token**. That token is then posted
/// to our own backend, which verifies it with Google and issues our session —
/// the client is never trusted to assert who the user is.
class GoogleAuthService extends GetxService {
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    try {
      await GoogleSignIn.instance.initialize(
        clientId: _orNull(GoogleAuthConfig.iosClientId),
        serverClientId: _orNull(GoogleAuthConfig.serverClientId),
      );
    } on UnimplementedError {
      // Windows/Linux/macOS desktop have no plugin implementation at all, so
      // the platform interface throws before any Google code runs.
      throw _unsupportedPlatform;
    }
    _initialized = true;
  }

  static const _unsupportedPlatform = GoogleAuthException(
    'unsupportedPlatform',
    'Google sign-in only works on Android or iOS. Run the app on a phone or '
        'an Android emulator.',
  );

  String? _orNull(String value) => value.isEmpty ? null : value;

  /// Starts the Google sign-in flow.
  ///
  /// Returns the ID token, or `null` when the user cancels the sheet.
  Future<String?> signIn() async {
    await _ensureInitialized();

    // False on web, which needs Google's own rendered button rather than
    // authenticate().
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw _unsupportedPlatform;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const GoogleAuthException(
          'missingIdToken',
          'Google returned no ID token. Check that serverClientId is the Web '
              'client ID.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw GoogleAuthException(error.code.name, error.description);
    }
  }

  /// Clears the cached Google account so the next sign-in shows the picker.
  Future<void> signOut() async {
    if (!_initialized) {
      return;
    }
    await GoogleSignIn.instance.signOut();
  }
}
