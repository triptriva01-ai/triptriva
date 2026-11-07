import 'package:flutter/material.dart';

import 'profile_theme.dart';

/// Full-bleed tinted band between the two white sheets. Hosts the
/// "Become triptriva partner" and "Back to triptriva" rows.
class ProfileBand extends StatelessWidget {
  const ProfileBand({
    required this.child,
    required this.onTap,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: ProfileGradients.band),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal:
                  ProfileSizes.pagePadding + ProfileSizes.bandHorizontalPadding,
              vertical: ProfileSizes.bandVerticalPadding,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Full-bleed white panel with page padding applied to its contents. Its
/// rounded edge casts a shadow onto the adjacent [ProfileBand].
class ProfileSheet extends StatelessWidget {
  const ProfileSheet({
    required this.child,
    required this.above,
    super.key,
  });

  /// Whether this sheet sits above the band (rounded bottom) or below it
  /// (rounded top).
  final bool above;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProfilePalette.white,
        borderRadius: above
            ? const BorderRadius.vertical(
                bottom: Radius.circular(ProfileSizes.sheetRadius),
              )
            : const BorderRadius.vertical(
                top: Radius.circular(ProfileSizes.sheetRadius),
              ),
        boxShadow:
            above ? ProfileShadows.sheetAbove : ProfileShadows.sheetBelow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ProfileSizes.pagePadding,
        ),
        child: child,
      ),
    );
  }
}
