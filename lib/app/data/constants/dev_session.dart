/// Stand-in for the signed-in user while the backend has no authentication.
///
/// `Triptriva.API` exposes no `/api/auth/*` routes yet, so nothing tells the
/// app who is logged in. Until that exists, screens that need "the current
/// user" resolve one through here.
///
/// TODO(auth): delete this once login returns a real user id and the
/// TokenStore holds a session.
abstract final class DevSession {
  /// A specific MongoDB user id to show, e.g. '507f1f77bcf86cd799439011'.
  ///
  /// Leave empty to fall back to the first user returned by
  /// `GET /api/users?limit=1`, which is convenient right after creating a
  /// user through Swagger.
  static const String userId = '';

  static bool get hasUserId => userId.isNotEmpty;
}
