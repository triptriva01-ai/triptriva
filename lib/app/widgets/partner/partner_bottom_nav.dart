import 'package:flutter/material.dart';

import 'partner_theme.dart';

/// Partner app shell navigation. The active destination gets a gradient pill
/// behind its icon and a gradient-filled label.
class PartnerBottomNav extends StatelessWidget {
  const PartnerBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const reservations = 0;
  static const quickUpdates = 1;
  static const revenue = 2;
  static const myBusiness = 3;

  static const _items = <_NavDestination>[
    _NavDestination(icon: Icons.calendar_month, label: 'Reservations'),
    _NavDestination(icon: Icons.sync, label: 'Quick Updates'),
    _NavDestination(icon: Icons.show_chart, label: 'Revenue'),
    _NavDestination(icon: Icons.business_center, label: 'My Business'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PartnerPalette.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PartnerSizes.headerRadius),
        ),
        boxShadow: PartnerShadows.bottomNav,
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          // A minimum, not a cap: a larger system font grows the bar rather
          // than clipping the labels.
          constraints: const BoxConstraints(minHeight: PartnerSizes.navHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PartnerSizes.navHorizontalPadding,
              vertical: 8,
            ),
            child: Row(
              children: [
                // Equal shares means four labels always fit, however narrow
                // the device.
                for (var index = 0; index < _items.length; index++)
                  Expanded(
                    child: _NavItem(
                      destination: _items[index],
                      isActive: currentIndex == index,
                      onTap: () => onTap(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavIcon(icon: destination.icon, isActive: isActive),
          const SizedBox(height: PartnerSizes.navIconToLabel),
          if (isActive)
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: PartnerGradients.prime.createShader,
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: PartnerStyle.navLabelActive,
              ),
            )
          else
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: PartnerStyle.navLabel,
            ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.isActive});

  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      icon,
      size: PartnerSizes.navIconSize,
      color: isActive ? PartnerPalette.white : PartnerPalette.navInactive,
    );

    if (!isActive) {
      return SizedBox(
        height: PartnerSizes.navPillHeight,
        child: Center(child: glyph),
      );
    }

    return Container(
      width: PartnerSizes.navPillWidth,
      height: PartnerSizes.navPillHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: PartnerGradients.prime,
        borderRadius: BorderRadius.circular(PartnerSizes.navPillRadius),
      ),
      child: glyph,
    );
  }
}
