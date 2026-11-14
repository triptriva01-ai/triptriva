import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/payment_constants.dart';
import '../controllers/payment_controller.dart';

/// Success page — the listing photo, then a card where the badge pops in,
/// the tick draws and confetti bursts, as in the three success frames.
class BookingSuccessView extends GetView<BookingSuccessController> {
  const BookingSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final reveal = controller.reveal;
    final badge = CurvedAnimation(
      parent: reveal,
      curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
    );
    final details = CurvedAnimation(
      parent: reveal,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: PaymentPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.goToExplore();
        },
        child: Scaffold(
          backgroundColor: PaymentPalette.white,
          body: Stack(
            children: [
              SizedBox(
                height: PaymentSizes.heroHeight,
                width: double.infinity,
                child: _Hero(url: controller.args.imageUrl, fade: details),
              ),
              Positioned.fill(
                top: PaymentSizes.heroHeight - PaymentSizes.sheetRadius,
                child: Container(
                  decoration: const BoxDecoration(
                    color: PaymentPalette.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(PaymentSizes.sheetRadius),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: PaymentSizes.heroHeight -
                    PaymentSizes.sheetRadius -
                    PaymentSizes.badgeSize / 2,
                left: 0,
                right: 0,
                child: Center(child: _Badge(scale: badge, tick: details)),
              ),
              Positioned.fill(
                top: PaymentSizes.heroHeight +
                    PaymentSizes.badgeSize / 2 -
                    PaymentSizes.sheetRadius +
                    24,
                child: _Details(controller: controller, badge: badge, fade: details),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.url, required this.fade});

  final String? url;

  /// Brand tint washes over the photo as the tick appears.
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    final image = url;
    const placeholder = ColoredBox(color: Color(0xFF3F3F3F));
    return Stack(
      fit: StackFit.expand,
      children: [
        image == null
            ? placeholder
            : Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
        FadeTransition(
          opacity: fade,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PaymentPalette.green.withValues(alpha: 0.55),
                  PaymentPalette.blue.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.scale, required this.tick});

  final Animation<double> scale;
  final Animation<double> tick;

  @override
  Widget build(BuildContext context) {
    const size = PaymentSizes.badgeSize;
    return SizedBox(
      width: size * 1.8,
      height: size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(opacity: tick, child: const _Confetti(size: size * 1.7)),
          ScaleTransition(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(PaymentSizes.badgeRing),
              decoration: const BoxDecoration(
                color: PaymentPalette.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: PaymentGradients.header,
                  shape: BoxShape.circle,
                ),
                child: ScaleTransition(
                  scale: tick,
                  child: const Icon(
                    Icons.check_rounded,
                    size: PaymentSizes.checkSize,
                    color: PaymentPalette.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A ring of small coloured dots and dashes around the badge.
class _Confetti extends StatelessWidget {
  const _Confetti({required this.size});

  final double size;

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFFFFB300),
    Color(0xFF8E24AA),
    PaymentPalette.green,
    PaymentPalette.blue,
  ];

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          for (var index = 0; index < 14; index++)
            Builder(
              builder: (context) {
                final angle = index * 2 * math.pi / 14 + (index.isEven ? 0.15 : -0.1);
                final distance = radius * (index.isEven ? 0.92 : 0.8);
                final dot = index % 3 != 0;
                return Positioned(
                  left: radius + distance * math.cos(angle) - 4,
                  top: radius + distance * math.sin(angle) - 4,
                  child: Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: dot ? 8 : 14,
                      height: dot ? 8 : 4,
                      decoration: BoxDecoration(
                        color: _colors[index % _colors.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.controller,
    required this.badge,
    required this.fade,
  });

  final BookingSuccessController controller;
  final Animation<double> badge;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PaymentSizes.pagePadding),
        child: Column(
          children: [
            FadeTransition(
              opacity: badge,
              child: const Text(PaymentStrings.success, style: PaymentStyle.successTitle),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: fade,
              child: const Text(
                PaymentStrings.bookingCompleted,
                textAlign: TextAlign.center,
                style: PaymentStyle.successBody,
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: fade,
              child: InkWell(
                onTap: controller.copyBookingId,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          PaymentStrings.bookingId(controller.args.bookingId),
                          style: PaymentStyle.bookingId,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.copy, size: 16, color: PaymentPalette.blue),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: badge,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.goToExplore,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(PaymentSizes.buttonHeight),
                        side: const BorderSide(color: PaymentPalette.green),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(PaymentSizes.buttonRadius),
                        ),
                      ),
                      child: const Text(
                        PaymentStrings.goToExplore,
                        style: PaymentStyle.outlineButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: PaymentGradients.prime,
                        borderRadius:
                            BorderRadius.circular(PaymentSizes.buttonRadius),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.goToReserve,
                          borderRadius:
                              BorderRadius.circular(PaymentSizes.buttonRadius),
                          child: const SizedBox(
                            height: PaymentSizes.buttonHeight,
                            child: Center(
                              child: Text(
                                PaymentStrings.goToReserve,
                                style: PaymentStyle.button,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
