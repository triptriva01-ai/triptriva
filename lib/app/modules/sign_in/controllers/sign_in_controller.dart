import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/constants/google_auth_config.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/apple_auth_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/google_auth_service.dart';
import '../../../modules/otp_verification/controllers/otp_controller.dart';
import '../../../routes/admin_guard.dart';
import '../../../routes/app_pages.dart';
import '../constants/sign_in_constants.dart';

class SignInController extends GetxController {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phonePattern = RegExp(r'^\+?\d{10,15}$');

  final GoogleAuthService _googleAuth = Get.find<GoogleAuthService>();
  final AppleAuthService _appleAuth = Get.find<AppleAuthService>();
  final AuthService _authService = Get.find<AuthService>();

  /// Accepts either a phone number or an email address.
  final identifierController = TextEditingController();
  final identifier = ''.obs;
  final isGoogleLoading = false.obs;
  final isAppleLoading = false.obs;
  final isSubmitting = false.obs;

  bool get canContinue {
    final value = identifier.value.trim();
    if (value.isEmpty) {
      return false;
    }
    return _emailPattern.hasMatch(value) ||
        _phonePattern.hasMatch(value.replaceAll(' ', ''));
  }

  @override
  void onInit() {
    super.onInit();
    identifierController.addListener(_syncIdentifier);
  }

  void _syncIdentifier() => identifier.value = identifierController.text;

  /// Requests a one-time code, then hands off to the verification screen.
  Future<void> submit() async {
    if (!canContinue) {
      Get.snackbar(
        SignInStrings.invalidIdentifierTitle,
        SignInStrings.invalidIdentifierMessage,
        duration: SignInDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    final value = identifier.value.trim();

    try {
      final result = await _authService.requestOtp(value);

      await Get.toNamed(
        Routes.OTP,
        arguments: OtpArgs(
          identifier: value,
          resendAfterSeconds:
              (result['resendAfterSeconds'] as num?)?.toInt() ?? 60,
          devCode: result['devCode'] as String?,
        ),
      );
    } on ApiException catch (error) {
      _error(error.message);
    } on SocketException catch (error, stackTrace) {
      Get.log('OTP request: socket failure: $error\n$stackTrace');
      _error(SignInStrings.backendUnreachable);
    } catch (error, stackTrace) {
      Get.log('OTP request failed: $error\n$stackTrace');
      _error('$error');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Google sign-in: get an ID token from Google, hand it to our backend, and
  /// store the session it returns.
  Future<void> signInWithGoogle() async {
    if (!GoogleAuthConfig.isConfigured) {
      _error(SignInStrings.googleNotConfigured);
      return;
    }
    if (isGoogleLoading.value) {
      return;
    }

    isGoogleLoading.value = true;
    try {
      final idToken = await _googleAuth.signIn();
      if (idToken == null) {
        // The user dismissed the Google sheet — not an error.
        return;
      }

      // AuthService stores the tokens returned by /api/auth/social.
      await _authService.socialLogin(provider: 'google', idToken: idToken);
      // Cache the signed-in user so AdminGuard can answer synchronously,
      // and so admins land in the admin panel rather than on Home.
      await AdminSession.ensureLoaded();
      await Get.offAllNamed(AdminSession.landingRoute());
    } on GoogleAuthException catch (error) {
      // Surface the provider's own code so setup problems are diagnosable.
      Get.log('Google sign-in failed: $error');
      _error('[${error.code}] ${error.description ?? ''}');
    } on ApiException catch (error) {
      _error(error.message);
    } on SocketException catch (error, stackTrace) {
      // The device could not open a socket at all. Log the full trace — the
      // host and port in it say which endpoint was unreachable — but show
      // the user something they can act on.
      Get.log('Google sign-in: socket failure: $error\n$stackTrace');
      _error(SignInStrings.backendUnreachable);
    } catch (error, stackTrace) {
      Get.log('Google sign-in failed: $error\n$stackTrace');
      _error('$error');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// Apple sign-in: same hand-off as Google, plus the nonce and the name
  /// Apple shares on the first sign-in only.
  Future<void> signInWithApple() async {
    if (!AppleAuthService.isSupported) {
      _error(SignInStrings.appleUnsupported);
      return;
    }
    if (isAppleLoading.value) {
      return;
    }

    isAppleLoading.value = true;
    try {
      final credential = await _appleAuth.signIn();
      if (credential == null) {
        // The user dismissed the Apple sheet — not an error.
        return;
      }

      await _authService.socialLogin(
        provider: 'apple',
        idToken: credential.idToken,
        name: credential.name,
        nonce: credential.rawNonce,
      );
      await AdminSession.ensureLoaded();
      await Get.offAllNamed(AdminSession.landingRoute());
    } on AppleAuthException catch (error) {
      Get.log('Apple sign-in failed: $error');
      _error('[${error.code}] ${error.description ?? ''}');
    } on ApiException catch (error) {
      _error(error.message);
    } on SocketException catch (error, stackTrace) {
      Get.log('Apple sign-in: socket failure: $error\n$stackTrace');
      _error(SignInStrings.backendUnreachable);
    } catch (error, stackTrace) {
      Get.log('Apple sign-in failed: $error\n$stackTrace');
      _error('$error');
    } finally {
      isAppleLoading.value = false;
    }
  }

  void _error(String message) {
    Get.snackbar(
      SignInStrings.signInFailedTitle,
      message,
      duration: SignInDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    identifierController
      ..removeListener(_syncIdentifier)
      ..dispose();
    super.onClose();
  }
}
