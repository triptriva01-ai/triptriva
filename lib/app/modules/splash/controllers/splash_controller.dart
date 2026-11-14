import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/providers/token_store.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/admin_guard.dart';
import '../../../routes/app_pages.dart';

/// Drives the splash timeline and decides where to go once it finishes.
///
/// The whole sequence runs off one [animationController] (0 → 1); the view
/// slices it into phases (see `SplashTimeline` in the view), so the pacing
/// can be tuned in one place without touching the navigation logic here.
class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 3400);
  static const _navigationHold = Duration(milliseconds: 350);

  late final AnimationController animationController;

  bool _canNavigate = true;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addStatusListener(_handleAnimationStatus);
  }

  @override
  void onReady() {
    super.onReady();
    final reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduceMotion) {
      // Skip straight to the final wordmark frame; completion still fires.
      animationController.animateTo(1, duration: Duration.zero);
    } else {
      animationController.forward();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _openNextScreen();
    }
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(_navigationHold);

    if (!_canNavigate) {
      return;
    }

    await Get.offAllNamed(await _resolveDestination());
  }

  /// Sends a returning user straight to Home instead of making them sign in
  /// again. The stored session is validated with a real call, so a revoked or
  /// long-expired one still lands on sign-in rather than a broken Home.
  Future<String> _resolveDestination() async {
    final tokenStore = Get.find<TokenStore>();

    if (!tokenStore.canRestoreSession) {
      return Routes.SIGN_IN;
    }

    try {
      // ApiClient silently refreshes the access token if this returns 401.
      final user = await Get.find<AuthService>().me();
      // Caching the user here both arms AdminGuard and decides whether a
      // returning admin reopens on the admin panel.
      AdminSession.remember(user);
      return AdminSession.landingRoute();
    } on ApiException catch (error) {
      Get.log('Stored session rejected: $error');

      // Only give up on the session if the server actually refused it — a
      // flat network failure should not sign the user out.
      if (error.isNetworkError) {
        return Routes.HOME;
      }

      await tokenStore.clear();
      return Routes.SIGN_IN;
    }
  }

  @override
  void onClose() {
    _canNavigate = false;
    animationController
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.onClose();
  }
}
