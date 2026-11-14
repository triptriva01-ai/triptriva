import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

/// Animated splash, rebuilt from the Figma "Splash screen 2" prototype:
///
/// 1. The location pin drops in, then the tent / paraglider / compass /
///    houseboat fly in around it and the radial dashes draw outward
///    (Component 8, resting state = `assets/splash/splash_composite.svg`).
/// 2. Everything collapses into the pin, which pulses while four burst ticks
///    flick out around it (`Frame 1000005344…47`).
/// 3. The pin gives way to the "trip trivia" wordmark (`Frame 1000005363`).
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
        body: DecoratedBox(
          // radial-gradient(106% 49% at 50% 50%, #2D9CDB 0%, #1F7A63 100%)
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 1.12,
              colors: [_SplashPalette.skyBlue, _SplashPalette.deepGreen],
            ),
          ),
          child: SizedBox.expand(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Figma: the 302 x 304 cluster sits centred on a 430-wide
                // frame, i.e. ~70% of the screen width.
                final boxWidth = math.min(
                  360.0,
                  math.max(240.0, constraints.maxWidth * 0.70),
                );
                return Center(
                  child: SizedBox(
                    width: boxWidth,
                    height: boxWidth * _Box.height / _Box.width,
                    child: AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, _) => _SplashStage(
                        t: controller.animationController.value,
                        scale: boxWidth / _Box.width,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One frame of the splash at timeline position [t] (0 → 1).
class _SplashStage extends StatelessWidget {
  const _SplashStage({required this.t, required this.scale});

  final double t;

  /// Screen pixels per Figma unit inside the 302 x 304 cluster box.
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _DashesPainter(
            t: t,
            scale: scale,
          ),
        ),
        for (var i = 0; i < _orbitIcons.length; i++)
          _orbitIcon(_orbitIcons[i], i),
        CustomPaint(painter: _BurstPainter(t: t, scale: scale)),
        _pin(),
        _wordmark(),
      ],
    );
  }

  /// Tent, paraglider, compass and houseboat: fly in from further out, hold,
  /// then get pulled into the pin.
  Widget _orbitIcon(_OrbitIcon icon, int index) {
    final inStart = SplashTimeline.orbitInStart + index * SplashTimeline.stagger;
    final flyIn = _phase(
      inStart,
      inStart + SplashTimeline.orbitInLength,
      Curves.easeOutCubic,
    );
    final outStart = SplashTimeline.collapseStart + index * 0.012;
    final collapse = _phase(
      outStart,
      outStart + SplashTimeline.collapseLength,
      Curves.easeInCubic,
    );

    // Distance from the pin, as a multiple of the resting distance.
    final distance = _lerp(1.9, 1, flyIn) * (1 - collapse);
    final size = _lerp(0.5, 1, flyIn) * _lerp(1, 0.25, collapse);
    final opacity = flyIn * (1 - collapse);
    if (opacity <= 0) return const SizedBox.shrink();

    final home = icon.center;
    final position = _Box.pin + (home - _Box.pin) * distance;

    return _layer(
      asset: icon.asset,
      anchor: home,
      position: position,
      size: size,
      opacity: opacity,
    );
  }

  Widget _pin() {
    final dropIn = _phase(0, SplashTimeline.pinInEnd, Curves.easeOutBack);
    final fadeIn = _phase(0, SplashTimeline.pinInEnd * 0.6, Curves.easeOut);
    final pulse = _phase(
      SplashTimeline.pulseStart,
      SplashTimeline.pulseEnd,
      Curves.easeInOut,
    );
    final exit = _phase(
      SplashTimeline.pinOutStart,
      SplashTimeline.pinOutEnd,
      Curves.easeInCubic,
    );

    final opacity = fadeIn * (1 - exit);
    if (opacity <= 0) return const SizedBox.shrink();

    // Pulse up and back down: 1 → 1.18 → 1.
    final pulseScale = 1 + 0.18 * math.sin(pulse * math.pi);
    return _layer(
      asset: _SplashAssets.pin,
      anchor: _Box.pin,
      position: _Box.pin + Offset(0, _lerp(-40, 0, dropIn)),
      size: _lerp(0.6, 1, dropIn) * pulseScale * _lerp(1, 0.4, exit),
      opacity: opacity,
    );
  }

  Widget _wordmark() {
    final reveal = _phase(
      SplashTimeline.wordmarkStart,
      SplashTimeline.wordmarkEnd,
      Curves.easeOutCubic,
    );
    if (reveal <= 0) return const SizedBox.shrink();

    final slide = _lerp(14, 0, reveal) * scale;
    final style = TextStyle(
      fontFamily: 'Poppins',
      color: Colors.white,
      fontSize: 32 * scale,
      height: 1,
      letterSpacing: 0,
    );

    return Center(
      child: Opacity(
        opacity: reveal,
        child: Transform.scale(
          scale: _lerp(0.88, 1, reveal),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(-slide, 0),
                child: Text(
                  'trip',
                  style: style.copyWith(fontWeight: FontWeight.w300),
                ),
              ),
              Transform.translate(
                offset: Offset(slide, 0),
                child: Text(
                  'trivia',
                  style: style.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  /// Draws a full-box SVG layer, scaled by [size] around [anchor] and moved
  /// so that [anchor] lands on [position] (both in Figma box units).
  Widget _layer({
    required String asset,
    required Offset anchor,
    required Offset position,
    required double size,
    required double opacity,
  }) {
    final a = anchor * scale;
    final p = position * scale;
    final matrix = Matrix4.identity()
      ..translateByDouble(p.dx, p.dy, 0, 1)
      ..scaleByDouble(size, size, 1, 1)
      ..translateByDouble(-a.dx, -a.dy, 0, 1);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform(
        transform: matrix,
        child: SvgPicture.asset(asset, fit: BoxFit.fill),
      ),
    );
  }

  double _phase(double start, double end, Curve curve) =>
      _interval(t, start, end, curve);
}

/// Phase boundaries as fractions of the 3.4 s timeline.
abstract final class SplashTimeline {
  static const pinInEnd = 0.16;
  static const orbitInStart = 0.08;
  static const orbitInLength = 0.20;
  static const stagger = 0.045;
  static const dashesInStart = 0.30;
  static const dashesInEnd = 0.42;
  static const collapseStart = 0.50;
  static const collapseLength = 0.13;
  static const dashesOutEnd = 0.58;
  static const pulseStart = 0.60;
  static const pulseEnd = 0.72;
  static const burstStart = 0.62;
  static const burstPeak = 0.70;
  static const burstEnd = 0.80;
  static const pinOutStart = 0.78;
  static const pinOutEnd = 0.86;
  static const wordmarkStart = 0.82;
  static const wordmarkEnd = 0.97;
}

/// The eight radial dashes from the composite: they draw outward from their
/// inner end, then retract when the icons collapse.
class _DashesPainter extends CustomPainter {
  const _DashesPainter({required this.t, required this.scale});

  final double t;
  final double scale;

  // (x1, y1) → (x2, y2) straight from splash_composite.svg, inner end first.
  static const _dashes = <(Offset, Offset)>[
    (Offset(72, 106), Offset(50, 90)),
    (Offset(224, 106), Offset(247, 90)),
    (Offset(221.043, 222.924), Offset(241.514, 241.802)),
    (Offset(71, 218), Offset(48, 234)),
    (Offset(113, 134), Offset(108, 131)),
    (Offset(190, 137), Offset(195, 134)),
    (Offset(183.323, 186.472), Offset(187.657, 190.277)),
    (Offset(124, 184), Offset(120, 187)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final grow = _interval(
      t,
      SplashTimeline.dashesInStart,
      SplashTimeline.dashesInEnd,
      Curves.easeOutCubic,
    );
    final retract = _interval(
      t,
      SplashTimeline.collapseStart,
      SplashTimeline.dashesOutEnd,
      Curves.easeInCubic,
    );
    if (grow <= 0 || retract >= 1) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 1 - retract)
      ..strokeWidth = 3 * scale;

    for (final (inner, outer) in _dashes) {
      // Grow from the inner end; retract back toward it.
      final end = Offset.lerp(inner, outer, grow * (1 - retract))!;
      canvas.drawLine(inner * scale, end * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashesPainter old) =>
      old.t != t || old.scale != scale;
}

/// Four ticks that flick out around the pin while it pulses
/// (Figma `Frame 1000005344…47`, 50 units from the pin, 20 long).
class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.t, required this.scale});

  final double t;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final grow = _interval(
      t,
      SplashTimeline.burstStart,
      SplashTimeline.burstPeak,
      Curves.easeOutCubic,
    );
    final fade = _interval(
      t,
      SplashTimeline.burstPeak,
      SplashTimeline.burstEnd,
      Curves.easeIn,
    );
    if (grow <= 0 || fade >= 1) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 1 - fade)
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;

    final centre = _Box.pin * scale;
    final inner = _lerp(38, 50, grow) + 8 * fade;
    final length = 20 * grow * (1 - fade * 0.6);

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        centre + dir * inner * scale,
        centre + dir * (inner + length) * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) =>
      old.t != t || old.scale != scale;
}

class _OrbitIcon {
  const _OrbitIcon(this.asset, this.center);

  final String asset;

  /// Resting centre of the icon inside the 302 x 304 box.
  final Offset center;
}

/// Clockwise from the top, matching the Figma Component 8 layer bounds.
const _orbitIcons = <_OrbitIcon>[
  _OrbitIcon(_SplashAssets.paraglider, Offset(151.7, 67.3)),
  _OrbitIcon(_SplashAssets.compass, Offset(244.2, 165)),
  _OrbitIcon(_SplashAssets.boat, Offset(148.5, 248.1)),
  _OrbitIcon(_SplashAssets.tent, Offset(60.5, 160.9)),
];

abstract final class _Box {
  static const width = 302.0;
  static const height = 304.0;

  /// Centre of the location pin (Figma `location`, 126,114 · 52 x 74).
  static const pin = Offset(152, 151);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// [curve] applied to where [t] sits between [start] and [end], clamped.
double _interval(double t, double start, double end, Curve curve) {
  if (t <= start) return 0;
  if (t >= end) return 1;
  return curve.transform((t - start) / (end - start));
}

abstract final class _SplashAssets {
  static const boat = 'assets/splash/layer_boat.svg';
  static const tent = 'assets/splash/layer_tent.svg';
  static const compass = 'assets/splash/layer_compass.svg';
  static const paraglider = 'assets/splash/layer_paraglider.svg';
  static const pin = 'assets/splash/layer_pin.svg';
}

abstract final class _SplashPalette {
  static const skyBlue = Color(0xFF2D9CDB);
  static const deepGreen = Color(0xFF1F7A63);
}
