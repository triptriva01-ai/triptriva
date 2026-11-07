import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// Thin wrapper around GetX's [GetConnect] that every service talks to.
///
/// Responsibilities:
///  * applies the base URL + timeouts,
///  * injects the bearer token on every request,
///  * decodes successful responses to their JSON body,
///  * converts any failure into a single [ApiException].
///
/// If you later prefer `dio`, this is the only file that needs rewriting — the
/// service classes only depend on the public method signatures below.
class ApiClient extends GetConnect {
  ApiClient({TokenStore? tokenStore})
      : _tokenStore = tokenStore ?? Get.find<TokenStore>();

  final TokenStore _tokenStore;

  @override
  void onInit() {
    httpClient.baseUrl = ApiConfig.baseUrl;
    httpClient.timeout = ApiConfig.connectTimeout;

    // Attach the auth token to every outgoing request.
    httpClient.addRequestModifier<Object?>((request) {
      final token = _tokenStore.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      return request;
    });

    // On a 401, swap the expired access token for a fresh one and let
    // GetConnect retry once. Without this the user is thrown back to sign-in
    // every time the access token expires, even though their refresh token is
    // still valid for weeks.
    httpClient.addAuthenticator<Object?>((request) async {
      if (await _refreshSession()) {
        request.headers['Authorization'] = 'Bearer ${_tokenStore.accessToken}';
      }
      return request;
    });
    httpClient.maxAuthRetries = 1;

    super.onInit();
  }

  /// Guards against recursion: the refresh call itself can return 401, which
  /// would otherwise re-enter the authenticator forever.
  bool _isRefreshing = false;

  /// Exchanges the stored refresh token for a new pair.
  /// Returns false (and clears the session) when it is no longer valid.
  Future<bool> _refreshSession() async {
    final refresh = _tokenStore.refreshToken;
    if (refresh == null || _isRefreshing) {
      return false;
    }

    _isRefreshing = true;
    try {
      final response = await post(
        AuthEndpoints.refreshToken,
        {'refreshToken': refresh},
      );

      final status = response.statusCode ?? 0;
      final body = response.body;

      if (status >= 200 && status < 300 && body is Map) {
        final accessToken = body['accessToken'];
        final refreshToken = body['refreshToken'];

        if (accessToken is String && refreshToken is String) {
          await _tokenStore.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          return true;
        }
      }

      // Expired, revoked, or already rotated — the session is unrecoverable.
      await _tokenStore.clear();
      return false;
    } catch (error) {
      // A network failure is not proof the session is invalid, so the tokens
      // are kept for the next attempt.
      Get.log('Token refresh failed: $error');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<dynamic> getRequest(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await get(path, query: _stringifyQuery(query));
    return _handle(response);
  }

  Future<dynamic> postRequest(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    final response = await post(path, body, query: _stringifyQuery(query));
    return _handle(response);
  }

  Future<dynamic> putRequest(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    final response = await put(path, body, query: _stringifyQuery(query));
    return _handle(response);
  }

  Future<dynamic> deleteRequest(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await delete(path, query: _stringifyQuery(query));
    return _handle(response);
  }

  /// Multipart upload helper used by the media / profile-image endpoints.
  ///
  /// [fieldName] must match the parameter name the controller binds, which is
  /// `file` for the avatar endpoint.
  Future<dynamic> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, String>? fields,
    bool usePut = true,
  }) async {
    final form = FormData({
      ...?fields,
      fieldName: MultipartFile(
        filePath,
        // Windows paths use backslashes; the server only needs the extension,
        // but sending "C:\...\img.jpg" as the filename is needlessly odd.
        filename: filePath.split(RegExp(r'[\\/]')).last,
        // The server accepts a file by its declared type (then checks the
        // bytes match), so the default octet-stream would be rejected.
        contentType: _contentTypeFor(filePath),
      ),
    });

    final response = usePut ? await put(path, form) : await post(path, form);
    return _handle(response);
  }

  /// Unwraps a [Response]: returns the decoded body on 2xx, otherwise throws a
  /// normalised [ApiException].
  dynamic _handle(Response<dynamic> response) {
    final status = response.statusCode;

    if (status != null && status >= 200 && status < 300) {
      return response.body;
    }

    if (status == null) {
      throw ApiException(
        message: response.statusText?.isNotEmpty == true
            ? response.statusText!
            : 'Network error. Please check your connection.',
      );
    }

    throw ApiException(
      statusCode: status,
      data: response.body,
      message: _extractMessage(response.body) ?? 'Request failed ($status).',
    );
  }

  /// Pulls a human-readable message out of the backend's error payloads.
  ///
  /// Triptriva.API produces two different shapes:
  ///  * `ExceptionHandlingMiddleware` → `{status, error, errors}`
  ///  * FluentValidation auto-validation → ASP.NET `ValidationProblemDetails`,
  ///    i.e. `{title, status, errors: {Field: [messages]}}`
  String? _extractMessage(dynamic body) {
    if (body is! Map) {
      return null;
    }

    if (body['error'] is String) {
      return body['error'] as String;
    }

    // Surface the first field error so validation failures are actionable.
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return '${first.first}';
      }
      if (first is String) {
        return first;
      }
    }

    for (final key in const ['title', 'message', 'detail']) {
      if (body[key] is String) {
        return body[key] as String;
      }
    }
    return null;
  }

  static String _contentTypeFor(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };
  }

  /// GetConnect expects query values as strings; coerce non-null entries.
  Map<String, dynamic>? _stringifyQuery(Map<String, dynamic>? query) {
    if (query == null) return null;
    final result = <String, dynamic>{};
    query.forEach((key, value) {
      if (value != null) result[key] = '$value';
    });
    return result;
  }
}
