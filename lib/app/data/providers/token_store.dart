import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Holds the auth tokens used by [ApiClient] to authenticate requests, and
/// persists them so the user stays signed in across app restarts.
///
/// Tokens are credentials, so they go in the platform keystore
/// (Android Keystore / iOS Keychain) rather than SharedPreferences, which is
/// plain text and readable on a rooted device.
///
/// The values are also cached in memory because [ApiClient] reads them
/// synchronously on every request; secure storage is only touched on
/// load/save/clear.
class TokenStore extends GetxService {
  static const _accessKey = 'triptriva.accessToken';
  static const _refreshKey = 'triptriva.refreshToken';

  // Defaults are the right choice on v10+: Android encrypts via DataStore and
  // the Keystore automatically, iOS uses the Keychain.
  static const _storage = FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isLoggedIn => _accessToken != null;

  /// True when a refresh token is available, so a new access token can be
  /// obtained even if the current one has expired.
  bool get canRestoreSession => _refreshToken != null;

  /// Reads any stored session. Call once, before the first route is built.
  Future<TokenStore> init() async {
    try {
      _accessToken = await _storage.read(key: _accessKey);
      _refreshToken = await _storage.read(key: _refreshKey);
    } catch (error) {
      // A reinstall or a wiped keystore leaves undecryptable entries. Treat
      // that as "signed out" rather than crashing on launch.
      Get.log('Could not read stored session: $error');
      _accessToken = null;
      _refreshToken = null;
      await clear();
    }
    return this;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> updateAccessToken(String accessToken) async {
    _accessToken = accessToken;
    await _storage.write(key: _accessKey, value: accessToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;

    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (error) {
      // The in-memory copy is already gone, which is what matters for the
      // current session.
      Get.log('Could not clear stored session: $error');
    }
  }
}
