import '../models/user.dart';

/// Who is allowed into the admin panel.
///
/// This is a **UI gate only**. It decides whether the app draws the admin
/// screens; it does not protect any data. Every `/api/admin/*` endpoint must
/// independently check the caller's role server-side — the backend already
/// has `UserRoles.Admin` for exactly that. Without the server check, anyone
/// can call those endpoints directly with any account, or patch this constant
/// out of the APK.
abstract final class AdminAccess {
  /// The designated admin account.
  ///
  /// Matching on an address is brittle — it breaks the moment the address
  /// changes and it cannot be revoked without shipping a new build — so the
  /// server-issued `role` is preferred and checked first. This stays as the
  /// bootstrap case, for before any account has been promoted to `admin`.
  static const email = 'triptriva01@gmail.com';

  /// True when [user] may see the admin panel.
  static bool allows(User? user) {
    if (user == null) return false;
    if (user.isAdmin) return true;
    return user.email.trim().toLowerCase() == email;
  }
}
