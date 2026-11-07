import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/providers/token_store.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/admin_guard.dart';
import '../../../routes/app_pages.dart';
import '../constants/admin_constants.dart';
import '../widgets/admin_nav.dart';
import 'admin_controller.dart';

/// Admin profile, and the edit form behind it.
class AdminProfileController extends AdminBaseController {
  @override
  int get tabIndex => AdminNav.profile;

  final AuthService _authService = Get.find<AuthService>();
  final TokenStore _tokenStore = Get.find<TokenStore>();

  final user = Rxn<User>();
  final isLoading = false.obs;
  final isSaving = false.obs;

  /// True while the edit form is showing instead of the settings list.
  final isEditing = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final loaded = await _authService.me();
      user.value = loaded;
      // Keep the guard's cache fresh while we are here.
      AdminSession.remember(loaded);
      _fillForm(loaded);
    } on ApiException catch (error) {
      Get.log('Admin profile load failed: $error');
      final cached = AdminSession.current;
      if (cached != null) {
        user.value = cached;
        _fillForm(cached);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _fillForm(User loaded) {
    nameController.text = loaded.name;
    emailController.text = loaded.email;
    phoneController.text = loaded.phone;
  }

  void startEditing() => isEditing.value = true;

  void stopEditing() {
    isEditing.value = false;
    final current = user.value;
    if (current != null) {
      _fillForm(current);
    }
  }

  Future<void> save() async {
    final current = user.value;
    if (current == null || isSaving.value) return;

    isSaving.value = true;
    try {
      final data = await adminService.updateProfile({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      });
      if (data is Map<String, dynamic>) {
        final updated = User.fromJson(data);
        user.value = updated;
        AdminSession.remember(updated);
      }
      isEditing.value = false;
    } on ApiException catch (error) {
      Get.log('Admin profile update failed: $error');
      Get.snackbar(
        AdminStrings.pendingTitle,
        error.message,
        duration: AdminDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Needs `image_picker` wiring like the traveller edit-profile screen.
  void changePicture() => pending(AdminStrings.changePicture);

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on ApiException catch (error) {
      // The local session is cleared regardless of the API result.
      Get.log('Logout request failed: $error');
      await _tokenStore.clear();
    }
    AdminSession.clear();
    await Get.offAllNamed(Routes.SIGN_IN);
  }
}
