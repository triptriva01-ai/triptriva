import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../models/user.dart';
import '../providers/api_client.dart';
import '../providers/token_store.dart';

/// Authentication & session management — backed by `AuthController`.
///
/// Every sign-in route returns the same payload, so [_session] is the single
/// place that stores the tokens and unwraps the user.
class AuthService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();
  final TokenStore _tokenStore = Get.find<TokenStore>();

  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'normal',
  }) async {
    final data = await _api.postRequest(
      AuthEndpoints.register,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      },
    );
    return _session(data);
  }

  /// [identifier] is an email address or a phone number — the sign-in screen
  /// has a single field for both.
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    final data = await _api.postRequest(
      AuthEndpoints.login,
      body: {'identifier': identifier, 'password': password},
    );
    return _session(data);
  }

  /// Google / Apple sign-in. [name] is only needed for Apple, which returns
  /// the user's name to the app once and never inside the token. [nonce] is
  /// the raw nonce whose SHA-256 was handed to the provider.
  Future<User> socialLogin({
    required String provider,
    required String idToken,
    String? name,
    String? nonce,
  }) async {
    final data = await _api.postRequest(
      AuthEndpoints.social,
      body: {
        'provider': provider,
        'idToken': idToken,
        'name': ?name,
        'nonce': ?nonce,
      },
    );
    return _session(data);
  }

  /// Sends a one-time code to a phone number or email address.
  ///
  /// Returns the raw response: `expiresInSeconds`, `resendAfterSeconds`, and
  /// `devCode` when the server is configured to expose it for local testing.
  Future<Map<String, dynamic>> requestOtp(String identifier) async {
    final data = await _api.postRequest(
      AuthEndpoints.otpRequest,
      body: {'identifier': identifier},
    );
    return (data as Map).cast<String, dynamic>();
  }

  /// Exchanges a code for a session. Creates the account if the identifier is
  /// new, which is why [name] is accepted.
  Future<User> verifyOtp({
    required String identifier,
    required String code,
    String? name,
  }) async {
    final data = await _api.postRequest(
      AuthEndpoints.otpVerify,
      body: {'identifier': identifier, 'code': code, 'name': ?name},
    );
    return _session(data);
  }

  /// Texts a code to [phone] so the signed-in user can add it to their
  /// account. Same response shape as [requestOtp]. 409 if another account
  /// already has the number.
  Future<Map<String, dynamic>> requestPhoneOtp(String phone) async {
    final data = await _api.postRequest(
      AuthEndpoints.phoneOtp,
      body: {'phone': phone},
    );
    return (data as Map).cast<String, dynamic>();
  }

  /// Saves [phone] on the signed-in account once [code] checks out.
  Future<User> verifyPhone({
    required String phone,
    required String code,
  }) async {
    final data = await _api.postRequest(
      AuthEndpoints.phoneVerify,
      body: {'phone': phone, 'code': code},
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// The signed-in user, resolved from the bearer token.
  Future<User> me() async {
    final data = await _api.getRequest(AuthEndpoints.me);
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// Exchanges the stored refresh token for a fresh pair. The old token is
  /// single-use — the server revokes it on rotation.
  Future<void> refreshSession() async {
    final refresh = _tokenStore.refreshToken;
    if (refresh == null) {
      return;
    }
    final data = await _api.postRequest(
      AuthEndpoints.refreshToken,
      body: {'refreshToken': refresh},
    );
    await _session(data);
  }

  Future<void> logout() async {
    final refresh = _tokenStore.refreshToken;
    if (refresh != null) {
      await _api.postRequest(
        AuthEndpoints.logout,
        body: {'refreshToken': refresh},
      );
    }
    await _tokenStore.clear();
  }

  Future<dynamic> registerDeviceToken(String fcmToken) => _api.postRequest(
        AuthEndpoints.deviceToken,
        body: {'token': fcmToken},
      );

  Future<dynamic> deregisterDeviceToken(String fcmToken) => _api.deleteRequest(
        AuthEndpoints.deviceToken,
        query: {'token': fcmToken},
      );

  /// Persists the tokens from an auth response and returns the user it
  /// carries. Awaited by every caller so the session is on disk before the app
  /// navigates away — otherwise being killed right after sign-in would lose it.
  Future<User> _session(dynamic data) async {
    final map = data as Map<String, dynamic>;

    final accessToken = map['accessToken'];
    final refreshToken = map['refreshToken'];
    if (accessToken is String && refreshToken is String) {
      await _tokenStore.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    return User.fromJson(map['user'] as Map<String, dynamic>);
  }
}
