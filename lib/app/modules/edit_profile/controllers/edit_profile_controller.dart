import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/user.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/providers/token_store.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/users_service.dart';
import '../constants/edit_profile_constants.dart';

/// Profile page FR-03 — edit name, email, phone, password and photo.
class EditProfileController extends GetxController {
  final UsersService _usersService = Get.find<UsersService>();
  final AuthService _authService = Get.find<AuthService>();
  final TokenStore _tokenStore = Get.find<TokenStore>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final user = Rxn<User>();
  final avatarUrl = ''.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingPhoto = false.obs;

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
    passwordController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    if (!_tokenStore.isLoggedIn) {
      _error(EditProfileStrings.signInRequired);
      return;
    }

    isLoading.value = true;
    try {
      final current = await _authService.me();
      _populate(current);
    } on ApiException catch (error) {
      _error(error.message);
    } finally {
      isLoading.value = false;
    }
  }

  void _populate(User current) {
    user.value = current;
    nameController.text = current.name;
    emailController.text = current.email;
    phoneController.text = current.phone;
    avatarUrl.value = current.avatarUrl ?? '';
    // Never prefill the password: we only ever hold the hash server-side, and
    // showing a placeholder would invite the user to "keep" a value that is
    // not their real password.
    passwordController.clear();
  }

  /// Picks an image and uploads it immediately, so the new photo is visible
  /// before the rest of the form is saved.
  Future<void> changePicture() async {
    if (isUploadingPhoto.value) {
      return;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // Downscale on the device: full-resolution camera images are several
        // megabytes and would hit the server's 5 MB limit.
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        return; // Cancelled — not an error.
      }

      isUploadingPhoto.value = true;
      final updated = await _usersService.uploadAvatar(picked.path);
      user.value = updated;
      avatarUrl.value = updated.avatarUrl ?? '';

      Get.snackbar(
        EditProfileStrings.savedTitle,
        EditProfileStrings.photoSavedMessage,
        duration: EditProfileDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (error) {
      _error(error.message);
    } catch (error) {
      Get.log('Avatar upload failed: $error');
      _error('$error');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Sends only the fields that actually changed, so a partial update never
  /// re-submits an unchanged email and trips the uniqueness check.
  Future<void> save() async {
    final current = user.value;
    if (current == null || isSaving.value) {
      return;
    }

    final name = _changed(nameController.text, current.name);
    final email = _changed(emailController.text, current.email);
    final phone = _changed(phoneController.text, current.phone);
    final password = passwordController.text.trim();

    if (name == null && email == null && phone == null && password.isEmpty) {
      _error(EditProfileStrings.nothingToSave);
      return;
    }

    isSaving.value = true;
    try {
      final updated = await _usersService.updateMe(
        name: name,
        email: email,
        phone: phone,
        password: password.isEmpty ? null : password,
      );
      _populate(updated);

      Get.snackbar(
        EditProfileStrings.savedTitle,
        EditProfileStrings.savedMessage,
        duration: EditProfileDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Hand the fresh user back so the Profile screen updates behind us.
      Get.back(result: updated);
    } on ApiException catch (error) {
      _error(error.message);
    } finally {
      isSaving.value = false;
    }
  }

  String? _changed(String input, String original) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || trimmed == original) {
      return null;
    }
    return trimmed;
  }

  void goBack() => Get.back();

  void _error(String message) {
    Get.snackbar(
      EditProfileStrings.failedTitle,
      message,
      duration: EditProfileDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
