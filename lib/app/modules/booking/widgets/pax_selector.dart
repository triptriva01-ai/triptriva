import 'package:flutter/material.dart';

import '../constants/booking_constants.dart';

/// "Number of people": the chosen count on a white card, then a slider with
/// the bounds and the live value under it.
class PaxSelector extends StatelessWidget {
  const PaxSelector({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // A minimum, not a cap: the card grows with the system font.
          constraints: const BoxConstraints(
            minHeight: BookingSizes.paxCardMinHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BookingPalette.white,
            borderRadius: BorderRadius.circular(
              BookingSizes.paxCardRadius,
            ),
          ),
          child: Text('$value', style: BookingStyle.paxValue),
        ),
        const SizedBox(height: BookingSizes.paxCardToSlider),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: BookingSizes.sliderTrackHeight,
            activeTrackColor: BookingPalette.green,
            inactiveTrackColor: BookingPalette.track,
            thumbColor: BookingPalette.white,
            overlayColor: BookingPalette.green.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: BookingSizes.sliderThumbRadius,
            ),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value.toDouble().clamp(
                  min.toDouble(),
                  max.toDouble(),
                ),
            min: min.toDouble(),
            max: max.toDouble(),
            // One stop per person: the count is always a whole number.
            divisions: (max - min) > 0 ? max - min : null,
            onChanged: (next) => onChanged(next.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$min', style: BookingStyle.sliderBound),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: BookingGradients.prime.createShader,
              child: Text('$value', style: BookingStyle.sliderValue),
            ),
            Text('$max', style: BookingStyle.sliderBound),
          ],
        ),
      ],
    );
  }
}
