import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _SplashPalette.deepGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: _SplashBody(controller: controller),
      ),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // radial-gradient(106% 49% at 50% 50%, #2D9CDB 0%, #1F7A63 100%)
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.01, 0),
          radius: 1.12,
          colors: [_SplashPalette.skyBlue, _SplashPalette.deepGreen],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Animated diagonal dashed "route" pattern.
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoutePatternPainter(
                    opacity: controller.routeOpacity.value,
                    progress: controller.routeProgress.value,
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boxSize = math.min(
                        340.0,
                        math.max(240.0, constraints.maxWidth * 0.78),
                      );
                      return SizedBox.square(
                        dimension: boxSize,
                        child: _IconCluster(
                          controller: controller,
                          boxSize: boxSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IconCluster extends StatelessWidget {
  const _IconCluster({required this.controller, required this.boxSize});

  final SplashController controller;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    // Positions/sizes are fractions of the cluster box, derived from the
    // Figma composite (Component 8, 302 x 304).
    final icons = <_IconSpec>[
      _IconSpec(
        asset: _SplashAssets.houseboat,
        fx: 0.49,
        fy: 0.82,
        widthFactor: 0.20,
        aspect: 73 / 144,
        reveal: controller.houseboat,
      ),
      _IconSpec(
        asset: _SplashAssets.tent,
        fx: 0.20,
        fy: 0.53,
        widthFactor: 0.16,
        aspect: 88 / 107,
        reveal: controller.tent,
      ),
      _IconSpec(
        asset: _SplashAssets.compass,
        fx: 0.81,
        fy: 0.54,
        widthFactor: 0.135,
        aspect: 1,
        reveal: controller.compass,
      ),
      _IconSpec(
        asset: _SplashAssets.paraglider,
        fx: 0.50,
        fy: 0.22,
        widthFactor: 0.145,
        aspect: 110 / 97,
        reveal: controller.paraglider,
      ),
      _IconSpec(
        asset: _SplashAssets.location,
        fx: 0.50,
        fy: 0.50,
        widthFactor: 0.19,
        aspect: 183 / 128,
        reveal: controller.location,
      ),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final spec in icons) _buildIcon(spec),
        // Wordmark sits just below the central pin, per the Figma text frame.
        Positioned(
          left: 0,
          right: 0,
          top: boxSize * 0.66,
          child: Transform.translate(
            offset: Offset(0, controller.titleOffset.value),
            child: Transform.scale(
              scale: controller.titleScale.value,
              child: Opacity(
                opacity: controller.titleOpacity.value,
                child: const Text(
                  'trip trivia',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(_IconSpec spec) {
    final width = boxSize * spec.widthFactor;
    final height = width * spec.aspect;
    return Positioned(
      left: boxSize * spec.fx - width / 2,
      top: boxSize * spec.fy - height / 2,
      width: width,
      height: height,
      child: Opacity(
        opacity: spec.reveal.opacity.value,
        child: Transform.scale(
          scale: spec.reveal.scale.value,
          child: SvgPicture.asset(spec.asset, width: width, height: height),
        ),
      ),
    );
  }
}

class _IconSpec {
  const _IconSpec({
    required this.asset,
    required this.fx,
    required this.fy,
    required this.widthFactor,
    required this.aspect,
    required this.reveal,
  });

  final String asset;
  final double fx;
  final double fy;
  final double widthFactor;
  final double aspect;
  final IconReveal reveal;
}

/// Diagonal dashed "route" pattern that drifts as [progress] advances and
/// fades in via [opacity]. Mirrors the Figma `Frame 1000005354/5361/5362`
/// dashed line frames behind the icon cluster.
class _RoutePatternPainter extends CustomPainter {
  const _RoutePatternPainter({required this.opacity, required this.progress});

  final double opacity;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final shortestSide = math.min(size.width, size.height);
    final routePaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2.0, shortestSide * 0.008)
      ..style = PaintingStyle.stroke;

    final bounds = Offset.zero & size;
    _paintRouteDashes(canvas, bounds, math.pi / 4, routePaint, 1);
    _paintRouteDashes(canvas, bounds, -math.pi / 4, routePaint, -1);
  }

  void _paintRouteDashes(
    Canvas canvas,
    Rect bounds,
    double rotation,
    Paint paint,
    double direction,
  ) {
    final shortestSide = math.min(bounds.width, bounds.height);
    final spacing = shortestSide * 0.2;
    final dashLength = spacing * 0.62;
    final travel = progress * spacing * 1.45 * direction;
    final reach = (bounds.longestSide / spacing).ceil() + 2;

    canvas.save();
    canvas.translate(bounds.center.dx, bounds.center.dy);
    canvas.rotate(rotation);

    for (var row = -reach; row <= reach; row++) {
      final y = row * spacing;
      final offset = row.isEven ? 0.0 : spacing * 0.7;

      for (var column = -reach; column <= reach; column++) {
        final x = column * spacing * 1.45 + offset + travel;
        canvas.drawLine(
          Offset(x - dashLength / 2, y),
          Offset(x + dashLength / 2, y),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoutePatternPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.progress != progress;
  }
}

abstract final class _SplashAssets {
  static const houseboat = 'assets/splash/houseboat.svg';
  static const tent = 'assets/splash/tent.svg';
  static const compass = 'assets/splash/compass.svg';
  static const paraglider = 'assets/splash/paraglider.svg';
  static const location = 'assets/splash/location.svg';
}

abstract final class _SplashPalette {
  static const skyBlue = Color(0xFF2D9CDB);
  static const deepGreen = Color(0xFF1F7A63);
}
