import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The "busy" spinner from the loading-page frames: a boat, a balloon and a
/// tent chasing each other round a ring, drawn in white over a dim veil.
class TripLoader extends StatefulWidget {
  const TripLoader({this.size = 96, this.color = Colors.white, super.key});

  final double size;
  final Color color;

  /// Dims the current screen and spins until [task] completes.
  static Future<T> during<T>(Future<T> Function() task) async {
    Get.dialog<void>(
      const PopScope(canPop: false, child: Center(child: TripLoader())),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
    );
    try {
      return await task();
    } finally {
      if (Get.isDialogOpen ?? false) Get.back<void>();
    }
  }

  @override
  State<TripLoader> createState() => _TripLoaderState();
}

class _TripLoaderState extends State<TripLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  static const _icons = [Icons.sailing, Icons.paragliding, Icons.festival];

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final iconSize = size * 0.34;
    final radius = (size - iconSize) / 2;
    return Semantics(
      label: 'Loading',
      child: SizedBox.square(
        dimension: size,
        child: AnimatedBuilder(
          animation: _spin,
          builder: (context, _) {
            final turn = _spin.value * 2 * math.pi;
            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(iconSize / 2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.color, width: 2),
                      ),
                    ),
                  ),
                ),
                for (var index = 0; index < _icons.length; index++)
                  Positioned(
                    left: radius +
                        radius * math.cos(turn + index * 2 * math.pi / 3 - math.pi / 2),
                    top: radius +
                        radius * math.sin(turn + index * 2 * math.pi / 3 - math.pi / 2),
                    child: Icon(_icons[index], size: iconSize, color: widget.color),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
