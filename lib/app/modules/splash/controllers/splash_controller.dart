import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/providers/token_store.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/admin_guard.dart';
import '../../../routes/app_pages.dart';

/// Opacity + scale pair used to "pop" a single icon into view.
class IconReveal {
  const IconReveal({required this.opacity, required this.scale});

  final Animation<double> opacity;
  final Animation<double> scale;
}

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 2200);
  static const _navigationHold = Duration(milliseconds: 500);

  late final AnimationController animationController;
  late final Animation<double> routeProgress;
  late final Animation<double> routeOpacity;

  // Each travel icon reveals on its own staggered interval, like the Figma
  // composite where tent / compass / paraglider / location animate in turn.
  late final IconReveal location;
  late final IconReveal paraglider;
  late final IconReveal compass;
  late final IconReveal tent;
  late final IconReveal houseboat;

  late final Animation<double> titleOpacity;
  late final Animation<double> titleScale;
  late final Animation<double> titleOffset;

  bool _canNavigate = true;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addStatusListener(_handleAnimationStatus);

    routeProgress = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );
    routeOpacity = Tween<double>(begin: 0, end: 0.6).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );

    location = _reveal(0.12, 0.44);
    paraglider = _reveal(0.22, 0.54);
    compass = _reveal(0.30, 0.62);
    tent = _reveal(0.38, 0.70);
    houseboat = _reveal(0.46, 0.78);

    titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.62, 0.92, curve: Curves.easeOut),
      ),
    );
    titleScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.62, 0.96, curve: Curves.easeOutCubic),
      ),
    );
    titleOffset = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.62, 0.96, curve: Curves.easeOutCubic),
      ),
    );
  }

  IconReveal _reveal(double start, double end) {
    return IconReveal(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      ),
      scale: Tween<double>(begin: 0.55, end: 1).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(
            start,
            math.min(1, end + 0.06),
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );
  }

  @override
  void onReady() {
    super.onReady();
    animationController.forward();
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
