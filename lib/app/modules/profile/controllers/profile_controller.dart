import 'package:get/get.dart';

import '../../../data/constants/dev_session.dart';
import '../../../data/models/user.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/providers/token_store.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/users_service.dart';
import '../../../routes/admin_guard.dart';
import '../../../routes/app_pages.dart';
import '../constants/profile_constants.dart';

/// Page 4 — Profile. Backs FR-01 … FR-08 of the user-side requirements.
class ProfileController extends GetxController {
  final UsersService _usersService = Get.find<UsersService>();
  final AuthService _authService = Get.find<AuthService>();
  final TokenStore _tokenStore = Get.find<TokenStore>();

  /// Index of the active bottom-nav destination (3 = Profile).
  static const profileTabIndex = 3;

  final name = ProfileStrings.placeholderName.obs;
  final phone = ProfileStrings.placeholderPhone.obs;
  final avatarUrl = ''.obs;
  final isLoading = false.obs;
  final currentTab = profileTabIndex.obs;

  /// Whether to offer the admin panel. See `admin_access.dart` — this only
  /// decides what is drawn; the server still has to check the role.
  final isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// The user currently shown. Null until [loadProfile] succeeds.
  final Rxn<User> user = Rxn<User>();

  /// FR-01 — load the profile from the backend's `UsersController`.
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final loaded = await _resolveCurrentUser();
      if (loaded != null) {
        user.value = loaded;
        // Keeps AdminGuard able to answer synchronously.
        AdminSession.remember(loaded);
        isAdmin.value = AdminSession.isAdmin;
        name.value = loaded.name;
        phone.value = loaded.phone;
        avatarUrl.value = loaded.avatarUrl ?? '';
      }
    } on ApiException catch (error) {
      // Server unreachable or the user was not found — keep the placeholder
      // values so the screen still renders during development.
      Get.log('Profile load failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  /// Prefers the signed-in user. Falls back to the dev shim only when there is
  /// no session yet, so the screen still renders before anyone has logged in.
  Future<User?> _resolveCurrentUser() async {
    if (_tokenStore.isLoggedIn) {
      return _authService.me();
    }
    if (DevSession.hasUserId) {
      return _usersService.getUser(DevSession.userId);
    }
    final users = await _usersService.getUsers(limit: 1);
    return users.isEmpty ? null : users.first;
  }

  /// FR-03 — edit profile. Partial update; omitted fields stay as they are.
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? language,
  }) async {
    final current = user.value;
    if (current == null) {
      return;
    }
    try {
      final updated = await _usersService.updateUser(
        current.id,
        name: name,
        email: email,
        phone: phone,
        language: language,
      );
      user.value = updated;
      this.name.value = updated.name;
      this.phone.value = updated.phone;
    } on ApiException catch (error) {
      Get.snackbar(
        ProfileStrings.pendingTitle,
        error.message,
        duration: ProfileDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openNotifications() => Get.toNamed(Routes.NOTIFICATIONS);

  /// Admin panel. Only reachable when [isAdmin]; [AdminGuard] turns away
  /// anyone who gets to the route another way.
  void openAdminPanel() => Get.toNamed(Routes.ADMIN_REVENUE);

  /// FR-02 — wishlist shortcut.
  void openWishlist() => Get.toNamed(Routes.WISHLIST);

  /// FR-03 — edit profile. Refreshes this screen with whatever comes back.
  Future<void> openEditProfile() async {
    final updated = await Get.toNamed(Routes.EDIT_PROFILE);
    if (updated is User) {
      user.value = updated;
      name.value = updated.name;
      phone.value = updated.phone;
      avatarUrl.value = updated.avatarUrl ?? '';
    }
  }

  /// FR-04 — partner registration banner. Opens the partner side of the app.
  // TODO(partner): route through onboarding/registration first for users who
  // are not partners yet.
  void openPartnerRegistration() => Get.toNamed(Routes.PARTNER_DASHBOARD);

  /// FR-05 — payment methods.
  void openPaymentMethods() => Get.toNamed(Routes.PAYMENT_METHODS);

  void openLanguage() => Get.toNamed(Routes.LANGUAGE);

  /// FR-06 — feedback module.
  void openFeedback() => Get.toNamed(Routes.FEEDBACK);

  /// FR-07 — privacy and data control.
  void openDataPrivacy() => _pending(ProfileStrings.dataPrivacy);

  void onTabSelected(int index) {
    if (index == currentTab.value) {
      return;
    }
    switch (index) {
      case 0:
        Get.offNamed(Routes.HOME);
      case 1:
        Get.offNamed(Routes.RESERVATIONS);
      case 2:
        Get.offNamed(Routes.WISHLIST);
    }
  }

  /// FR-08 — secure logout: clear the session, then return to sign in.
  Future<void> logout() async {
    try {
      // Revokes the refresh token server-side, then clears local tokens.
      await _authService.logout();
    } on ApiException catch (error) {
      // The local session is cleared regardless of the API result.
      Get.log('Logout request failed: $error');
      await _tokenStore.clear();
    }

    AdminSession.clear();
    await Get.offAllNamed(Routes.SIGN_IN);
  }

  void _pending(String feature) {
    Get.snackbar(
      ProfileStrings.pendingTitle,
      ProfileStrings.pendingMessage(feature),
      duration: ProfileDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
