import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../models/user.dart';
import '../providers/api_client.dart';

/// The `UsersController` CRUD slice — the only part of Triptriva.API that is
/// implemented today. Unlike the other services (which still return raw JSON
/// for endpoints that do not exist yet), this one returns typed [User]s.
class UsersService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// GET /api/users?page=&limit=&role=
  ///
  /// The server clamps `limit` to 1..100 and falls back to 20 outside that.
  Future<List<User>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
  }) async {
    final data = await _api.getRequest(
      UsersEndpoints.users,
      query: {'page': page, 'limit': limit, 'role': role},
    );
    if (data is! List) {
      return const [];
    }
    return data.whereType<Map<String, dynamic>>().map(User.fromJson).toList();
  }

  /// GET /api/users/{id} — 404 when the user does not exist.
  Future<User> getUser(String id) async {
    final data = await _api.getRequest(UsersEndpoints.detail(id));
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// POST /api/users — 409 if the email or phone is already registered.
  /// Password must be at least 8 characters; the server bcrypt-hashes it.
  Future<User> createUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'normal',
  }) async {
    final data = await _api.postRequest(
      UsersEndpoints.users,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      },
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /api/users/me — Edit Profile for the signed-in user.
  /// Omitted fields are left untouched; [password] sets a new one.
  Future<User> updateMe({
    String? name,
    String? email,
    String? phone,
    String? language,
    String? password,
  }) async {
    final data = await _api.putRequest(
      '${UsersEndpoints.users}/me',
      body: {
        'name': ?name,
        'email': ?email,
        'phone': ?phone,
        'language': ?language,
        'password': ?password,
      },
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /api/users/me/avatar — multipart upload of the profile photo.
  /// Returns the updated user, whose `avatarUrl` is an absolute URL.
  Future<User> uploadAvatar(String filePath) async {
    final data = await _api.uploadFile(
      '${UsersEndpoints.users}/me/avatar',
      filePath: filePath,
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /api/users/{id} — partial update; omitted fields are left untouched.
  Future<User> updateUser(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? language,
  }) async {
    final data = await _api.putRequest(
      UsersEndpoints.detail(id),
      body: {
        'name': ?name,
        'email': ?email,
        'phone': ?phone,
        'language': ?language,
      },
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// DELETE /api/users/{id} — 204 on success.
  Future<void> deleteUser(String id) =>
      _api.deleteRequest(UsersEndpoints.detail(id));
}
