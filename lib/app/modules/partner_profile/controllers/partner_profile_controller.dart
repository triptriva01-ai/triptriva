import 'package:get/get.dart';

import '../../../data/constants/api_endpoints.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/providers/token_store.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/partner_service.dart';
import '../../../routes/app_pages.dart';
import '../../account_settings/constants/account_settings_constants.dart';
import '../constants/partner_profile_constants.dart';

/// Partner-side Page 06 — Profile.
class PartnerProfileController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();
  final AuthService _authService = Get.find<AuthService>();
  final TokenStore _tokenStore = Get.find<TokenStore>();

  final name = PartnerProfileStrings.placeholderName.obs;
  final phone = PartnerProfileStrings.placeholderPhone.obs;
  final avatarUrl = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// FR-01 — profile picture and name loaded from the partner profile API.
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final data = await _partnerService.getProfile();
      final user = data['user'];
      if (user is Map) {
        name.value = _readString(user, 'name') ?? name.value;
        // OTP-by-email and Google accounts may have no phone; show the email.
        phone.value =
            _readString(user, 'phone') ?? _readString(user, 'email') ?? '';
        avatarUrl.value = ApiConfig.mediaUrl(
          _readString(user, 'avatarUrl') ?? avatarUrl.value,
        );
      }
    } on ApiException catch (error) {
      Get.log('Partner profile load failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  String? _readString(Map<dynamic, dynamic> source, String key) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  void goBack() => Get.back();

  /// FR-02 — "Back to triptriva" returns the partner to the traveller app.
  Future<void> backToTripTrivia() async {
    await Get.offAllNamed(Routes.HOME);
  }

  /// FR-03 — payment methods and payout details.
  void openPaymentMethods() => Get.toNamed(Routes.PAYMENT_METHODS);

  void openLanguage() => Get.toNamed(Routes.LANGUAGE);

  void openFeedback() => Get.toNamed(Routes.FEEDBACK);

  // No design yet for data control & privacy.
  void openDataPrivacy() => _pending(PartnerProfileStrings.dataPrivacy);

  void openCustomerSupport() => Get.toNamed(Routes.CUSTOMER_SUPPORT);

  void openAbout() =>
      Get.toNamed(Routes.ABOUT, arguments: AboutAudience.partner);

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on ApiException catch (error) {
      // The local session is cleared regardless of the API result.
      Get.log('Logout request failed: $error');
    }

    await _tokenStore.clear();
    _partnerService.clearCache();
    await Get.offAllNamed(Routes.SIGN_IN);
  }

  void _pending(String feature) {
    Get.snackbar(
      PartnerProfileStrings.pendingTitle,
      PartnerProfileStrings.pendingMessage(feature),
      duration: PartnerProfileDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
