import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/constants/admin_access.dart';
import '../data/models/user.dart';
import '../data/providers/token_store.dart';
import '../data/services/auth_service.dart';
import 'app_pages.dart';

/// Keeps non-admins out of the admin routes.
///
/// [redirect] runs synchronously before the page is built, so it can only use
/// what is already in memory — the user cached by [AdminSession]. The session
/// is refreshed on sign-in and whenever the profile loads, which is what makes
/// the cache trustworthy enough for a UI gate.
///
/// Again: this hides the screens, it does not protect the data. The
/// `/api/admin/*` endpoints must enforce the `admin` role themselves.
class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AdminAccess.allows(AdminSession.current)) {
      return null;
    }
    // Send them back where they came from rather than to a dead end.
    return const RouteSettings(name: Routes.PROFILE);
  }
}

/// The signed-in user, cached so [AdminGuard] can answer synchronously.
abstract final class AdminSession {
  static User? _current;

  static User? get current => _current;

  /// Called after sign-in and whenever a fresh profile is fetched.
  static void remember(User? user) => _current = user;

  static void clear() => _current = null;

  static bool get isAdmin => AdminAccess.allows(_current);

  /// Where to land once authenticated.
  ///
  /// Every entry point — Google sign-in, OTP verification and the splash
  /// session restore — goes through here, so an admin lands in the admin
  /// panel no matter how they got in.
  static String landingRoute() =>
      isAdmin ? Routes.ADMIN_REVENUE : Routes.HOME;

  /// Fetches the current user when the cache is cold, e.g. after a cold start
  /// straight into a deep link. Safe to call when signed out.
  static Future<User?> ensureLoaded() async {
    if (_current != null) return _current;
    if (!Get.find<TokenStore>().isLoggedIn) return null;
    try {
      _current = await Get.find<AuthService>().me();
    } on Object catch (error) {
      Get.log('Admin session load failed: $error');
    }
    return _current;
  }
}
