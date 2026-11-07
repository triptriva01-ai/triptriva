import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Admin panel — covers Revenue, Activities, Users and Profile sheets
/// (`Admin Revenue`, `Admin Activities`, `Admin Users`, `Admin Profile`).
class AdminService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  // ---- Revenue dashboard (Page 1) ----------------------------------------
  Future<dynamic> revenueSummary() =>
      _api.getRequest(AdminRevenueEndpoints.summary);

  Future<dynamic> revenueGrowthCurve() =>
      _api.getRequest(AdminRevenueEndpoints.growthCurve);

  Future<dynamic> revenueCategories() =>
      _api.getRequest(AdminRevenueEndpoints.categories);

  Future<dynamic> revenueBookings({Map<String, dynamic>? query}) =>
      _api.getRequest(AdminRevenueEndpoints.bookings, query: query);

  // ---- Activities management (Page 2) ------------------------------------
  /// All activities. Filter: status (accepted/pending), category, page, limit.
  Future<dynamic> getActivities({Map<String, dynamic>? query}) =>
      _api.getRequest(AdminActivityEndpoints.activities, query: query);

  Future<dynamic> activityAnalytics() =>
      _api.getRequest(AdminActivityEndpoints.analytics);

  Future<dynamic> getActivity(String id) =>
      _api.getRequest(AdminActivityEndpoints.detail(id));

  Future<dynamic> acceptActivity(String id) =>
      _api.putRequest(AdminActivityEndpoints.accept(id));

  Future<dynamic> rejectActivity(String id) =>
      _api.putRequest(AdminActivityEndpoints.reject(id));

  // ---- Users management (Page 3) -----------------------------------------
  /// All users. Filter: type (all/partner/normal), page, limit.
  Future<dynamic> getUsers({Map<String, dynamic>? query}) =>
      _api.getRequest(AdminUserEndpoints.users, query: query);

  Future<dynamic> getUser(String id) =>
      _api.getRequest(AdminUserEndpoints.detail(id));

  /// Activate / deactivate a user account. status: active/inactive.
  Future<dynamic> setUserStatus(String id, String status) => _api.putRequest(
        AdminUserEndpoints.status(id),
        body: {'status': status},
      );

  Future<dynamic> deleteUser(String id) =>
      _api.deleteRequest(AdminUserEndpoints.delete(id));

  // ---- Profile & notifications (Page 4) ----------------------------------
  Future<dynamic> getProfile() =>
      _api.getRequest(AdminProfileEndpoints.profile);

  Future<dynamic> updateProfile(Map<String, dynamic> body) =>
      _api.putRequest(AdminProfileEndpoints.profile, body: body);

  Future<dynamic> updateProfileImage(String filePath) =>
      _api.uploadFile(AdminProfileEndpoints.profileImage, filePath: filePath);

  Future<dynamic> getPaymentMethods() =>
      _api.getRequest(AdminProfileEndpoints.paymentMethods);

  Future<dynamic> getLanguage() =>
      _api.getRequest(AdminProfileEndpoints.language);

  Future<dynamic> setLanguage(String languageCode) => _api.putRequest(
        AdminProfileEndpoints.language,
        body: {'languageCode': languageCode},
      );

  Future<dynamic> getNotifications() =>
      _api.getRequest(AdminProfileEndpoints.notifications);

  Future<dynamic> markNotificationRead(String id) =>
      _api.putRequest(AdminProfileEndpoints.notificationRead(id));
}
