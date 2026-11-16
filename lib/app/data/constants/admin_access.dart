import '../models/user.dart';

/// Who is allowed into the admin panel.
///
/// This is a **UI gate only**: it decides whether the app draws the admin
/// screens. The backend enforces the same rule on every `/api/admin/*`
/// endpoint (admin role AND an email on `AdminAccess:Emails`), so patching
/// this out of the app opens nothing.
abstract final class AdminAccess {
  /// The only account allowed into the admin panel.
  static const email = 'triptriva01@gmail.com';

  /// True when [user] may see the admin panel: the server-issued admin role
  /// and the admin email, both. Either alone is not enough.
  static bool allows(User? user) {
    if (user == null) return false;
    return user.isAdmin && user.email.trim().toLowerCase() == email;
  }
}
