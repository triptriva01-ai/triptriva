import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Profile page — `Profile` sheet (Page 4).
class ProfileService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  Future<dynamic> getProfile() => _api.getRequest(ProfileEndpoints.profile);

  /// Edit profile — name, email, phone, password.
  Future<dynamic> updateProfile(Map<String, dynamic> body) =>
      _api.putRequest(ProfileEndpoints.profile, body: body);

  /// Upload / update profile photo (multipart/form-data).
  Future<dynamic> updateProfileImage(String filePath) =>
      _api.uploadFile(ProfileEndpoints.profileImage, filePath: filePath);

  Future<dynamic> getPaymentMethods() =>
      _api.getRequest(ProfileEndpoints.paymentMethods);

  Future<dynamic> addPaymentMethod(Map<String, dynamic> body) =>
      _api.postRequest(ProfileEndpoints.paymentMethods, body: body);

  Future<dynamic> updatePaymentMethod(String id, Map<String, dynamic> body) =>
      _api.putRequest(ProfileEndpoints.paymentMethod(id), body: body);

  Future<dynamic> removePaymentMethod(String id) =>
      _api.deleteRequest(ProfileEndpoints.paymentMethod(id));

  /// [category] is one of bug, suggestion, complaint, praise, support or other.
  Future<dynamic> submitFeedback(
    String message, {
    String? category,
    String? platform,
  }) =>
      _api.postRequest(
        ProfileEndpoints.feedback,
        body: {
          'message': message,
          'category': ?category,
          'platform': ?platform,
        },
      );

  Future<dynamic> getLanguage() => _api.getRequest(ProfileEndpoints.language);

  Future<dynamic> setLanguage(String languageCode) => _api.putRequest(
        ProfileEndpoints.language,
        body: {'languageCode': languageCode},
      );

  /// Submit partner registration application from the profile banner.
  Future<dynamic> registerAsPartner(Map<String, dynamic> body) =>
      _api.postRequest(ProfileEndpoints.partnerRegister, body: body);
}
