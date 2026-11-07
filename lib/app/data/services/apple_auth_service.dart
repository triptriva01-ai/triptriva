import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Raised when Sign in with Apple fails for a reason other than the user
/// cancelling, carrying the provider's own code so setup problems are visible.
class AppleAuthException implements Exception {
  const AppleAuthException(this.code, [this.description]);

  final String code;
  final String? description;

  @override
  String toString() => 'AppleAuthException($code): $description';
}

/// What the backend needs from a successful Apple sign-in.
class AppleCredential {
  const AppleCredential({
    required this.idToken,
    required this.rawNonce,
    this.name,
  });

  final String idToken;

  /// Sent to the backend, which checks the token carries its SHA-256 — so a
  /// token captured from another sign-in cannot be replayed.
  final String rawNonce;

  /// Apple shares the name on the user's FIRST sign-in only, never again and
  /// never inside the token — the backend stores it when creating the account.
  final String? name;
}

/// Thin wrapper around the native Sign in with Apple sheet.
///
/// Like [GoogleAuthService], its only job is to return an ID token for our
/// backend to verify. Native sign-in exists on iOS and macOS only; Android
/// would need Apple's web flow plus a server callback, which isn't set up.
class AppleAuthService extends GetxService {
  static bool get isSupported => Platform.isIOS || Platform.isMacOS;

  /// Returns the credential, or `null` when the user cancels the sheet.
  Future<AppleCredential?> signIn() async {
    if (!isSupported || !await SignInWithApple.isAvailable()) {
      throw const AppleAuthException(
        'unsupportedPlatform',
        'Sign in with Apple is available on iPhone and iPad.',
      );
    }

    final rawNonce = _generateNonce();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AppleAuthException(
          'missingIdToken',
          'Apple returned no identity token.',
        );
      }

      final name = [credential.givenName, credential.familyName]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ');

      return AppleCredential(
        idToken: idToken,
        rawNonce: rawNonce,
        name: name.isEmpty ? null : name,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      throw AppleAuthException(error.code.name, error.message);
    }
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}
