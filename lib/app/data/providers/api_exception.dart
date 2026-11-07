/// Normalised error thrown by [ApiClient] for any non-successful request so
/// controllers can handle a single error type instead of raw HTTP details.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  /// Human-readable message safe to surface in a snackbar.
  final String message;

  /// HTTP status code when the request reached the server (null on timeout /
  /// no connection).
  final int? statusCode;

  /// Raw decoded error body, when the backend returned one.
  final dynamic data;

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
