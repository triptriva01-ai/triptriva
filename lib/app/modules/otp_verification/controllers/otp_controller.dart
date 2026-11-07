import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/admin_guard.dart';
import '../constants/otp_constants.dart';

/// Arguments handed to the OTP screen by the sign-in screen.
class OtpArgs {
  const OtpArgs({
    required this.identifier,
    this.resendAfterSeconds = 60,
    this.devCode,
  });

  /// The phone number or email the code was sent to.
  final String identifier;
  final int resendAfterSeconds;

  /// Present only while the server exposes codes for local testing.
  final String? devCode;
}

class OtpController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final codeController = TextEditingController();
  final code = ''.obs;
  final isVerifying = false.obs;
  final isResending = false.obs;
  final secondsUntilResend = 0.obs;
  final devCode = RxnString();

  late final String identifier;

  Timer? _ticker;

  bool get canVerify => code.value.length == OtpSizes.codeLength;
  bool get canResend => secondsUntilResend.value == 0 && !isResending.value;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    identifier = args is OtpArgs ? args.identifier : '';
    devCode.value = args is OtpArgs ? args.devCode : null;

    codeController.addListener(_syncCode);
    _startCooldown(args is OtpArgs ? args.resendAfterSeconds : 60);
  }

  @override
  void onClose() {
    _ticker?.cancel();
    codeController
      ..removeListener(_syncCode)
      ..dispose();
    super.onClose();
  }

  void _syncCode() {
    code.value = codeController.text;

    // Six digits is the whole input, so submit without making the user reach
    // for the button.
    if (code.value.length == OtpSizes.codeLength && !isVerifying.value) {
      verify();
    }
  }

  void _startCooldown(int seconds) {
    _ticker?.cancel();
    secondsUntilResend.value = seconds;

    _ticker = Timer.periodic(OtpDurations.tick, (timer) {
      if (secondsUntilResend.value <= 1) {
        secondsUntilResend.value = 0;
        timer.cancel();
        return;
      }
      secondsUntilResend.value--;
    });
  }

  Future<void> verify() async {
    if (!canVerify) {
      _error(OtpStrings.shortCode);
      return;
    }
    if (isVerifying.value) {
      return;
    }

    isVerifying.value = true;
    try {
      // AuthService stores the tokens the server returns.
      await _authService.verifyOtp(
        identifier: identifier,
        code: code.value,
      );
      // Cache the signed-in user so AdminGuard can answer synchronously,
      // and so admins land in the admin panel rather than on Home.
      await AdminSession.ensureLoaded();
      await Get.offAllNamed(AdminSession.landingRoute());
    } on ApiException catch (error) {
      _error(error.message);
      codeController.clear();
    } catch (error) {
      Get.log('OTP verify failed: $error');
      _error('$error');
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resend() async {
    if (!canResend) {
      return;
    }

    isResending.value = true;
    try {
      final result = await _authService.requestOtp(identifier);
      devCode.value = result['devCode'] as String?;
      _startCooldown((result['resendAfterSeconds'] as num?)?.toInt() ?? 60);

      Get.snackbar(
        OtpStrings.sentTitle,
        OtpStrings.sentMessage,
        duration: OtpDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (error) {
      // The server also enforces the cooldown; surface its message verbatim.
      _error(error.message);
    } finally {
      isResending.value = false;
    }
  }

  void goBack() => Get.back();

  void _error(String message) {
    Get.snackbar(
      OtpStrings.failedTitle,
      message,
      duration: OtpDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
