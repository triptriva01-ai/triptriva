import 'package:flutter/material.dart';

import '../constants/wishlist_constants.dart';

/// "No More Wishes" — the end-of-list marker under the grid, and the whole
/// message when nothing is saved yet.
///
/// The Figma illustration has not been exported, so the placeholder below is
/// drawn from the brand gradient rather than an asset; swap in the image here
/// once it lands and the rest of the screen stays as it is.
class NoMoreWishes extends StatelessWidget {
  const NoMoreWishes({this.showIllustration = false, super.key});

  /// The empty state shows the illustration; the end-of-list marker is just
  /// the gradient label.
  final bool showIllustration;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIllustration) ...[
          const _WishIllustration(),
          const SizedBox(height: WishlistSizes.dividerToLabel),
        ],
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: WishlistGradients.prime.createShader,
          child: const Text(
            WishlistStrings.noMoreWishes,
            textAlign: TextAlign.center,
            style: WishlistStyle.noMoreWishes,
          ),
        ),
        if (showIllustration) ...[
          const SizedBox(height: 12),
          const Text(
            WishlistStrings.emptyHint,
            textAlign: TextAlign.center,
            style: WishlistStyle.emptyHint,
          ),
        ],
      ],
    );
  }
}

class _WishIllustration extends StatelessWidget {
  const _WishIllustration();

  @override
  Widget build(BuildContext context) {
    // Never larger than the space available, so it cannot force the column
    // wider than a narrow phone.
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, WishlistSizes.illustrationSize)
            : WishlistSizes.illustrationSize;

        return SizedBox(
          width: size,
          height: size,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: WishlistGradients.prime.createShader,
            child: Icon(
              Icons.favorite_border,
              size: size * 0.7,
              color: WishlistPalette.white,
            ),
          ),
        );
      },
    );
  }
}

/// Hairline between the last row of cards and the end-of-list marker.
class WishlistDivider extends StatelessWidget {
  const WishlistDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(color: WishlistPalette.divider),
    );
  }
}
