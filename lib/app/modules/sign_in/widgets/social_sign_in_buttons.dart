import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/sign_in_constants.dart';
import '../controllers/sign_in_controller.dart';

/// Google and Apple sign-in tiles.
class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({required this.controller, super.key});

  final SignInController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => _SocialTile(
            onTap: controller.signInWithGoogle,
            child: controller.isGoogleLoading.value
                ? const SizedBox.square(
                    dimension: SignInSizes.socialIconSize,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const CustomPaint(
                    size: Size.square(SignInSizes.socialIconSize),
                    painter: _GoogleLogoPainter(),
                  ),
          ),
        ),
        const SizedBox(width: SignInSizes.socialGap),
        Obx(
          () => _SocialTile(
            onTap: controller.signInWithApple,
            child: controller.isAppleLoading.value
                ? const SizedBox.square(
                    dimension: SignInSizes.socialIconSize,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.apple,
                    size: SignInSizes.socialIconSize + 6,
                    color: SignInPalette.black,
                  ),
          ),
        ),
      ],
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SignInPalette.white,
        border: Border.all(color: SignInPalette.socialBorder),
        borderRadius: BorderRadius.circular(SignInSizes.socialRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SignInSizes.socialRadius),
          child: SizedBox.square(
            dimension: SignInSizes.socialSize,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Approximation of the four-colour Google mark.
///
/// TODO(design): replace with the official `google.svg` asset from Google's
/// sign-in branding guidelines before release — using the official artwork is
/// a branding requirement.
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Ring quarters, starting at the right and running clockwise.
    canvas.drawArc(rect, -math.pi / 4, math.pi / 2, false, paint..color = _blue);
    canvas.drawArc(rect, math.pi / 4, math.pi / 2, false, paint..color = _green);
    canvas.drawArc(
      rect,
      3 * math.pi / 4,
      math.pi / 2,
      false,
      paint..color = _yellow,
    );
    canvas.drawArc(
      rect,
      -3 * math.pi / 4,
      math.pi / 2,
      false,
      paint..color = _red,
    );

    // The blue crossbar running into the centre of the G.
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.5,
        size.height * 0.39,
        size.width,
        size.height * 0.61,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
