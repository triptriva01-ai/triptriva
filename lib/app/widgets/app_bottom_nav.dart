import 'package:flutter/material.dart';

/// User-side app shell navigation, shared by Explore / Reservations /
/// Wishlist / Profile. The active destination is filled with the brand
/// gradient.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const explore = 0;
  static const reservations = 1;
  static const wishlist = 2;
  static const profile = 3;

  static const _height = 72.0;
  static const _radius = 40.0;
  static const _horizontalPadding = 30.0;
  static const _iconSize = 20.0;
  static const _iconToLabel = 8.0;
  static const _inactive = Color(0xFF7B7B7B);

  static const _gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1F7A63), Color(0xFF2D9CDB)],
  );

  static const _items = <_NavDestination>[
    _NavDestination(icon: Icons.search, label: 'Explore'),
    _NavDestination(icon: Icons.calendar_month, label: 'Reservations'),
    _NavDestination(icon: Icons.favorite, label: 'Wishlist'),
    _NavDestination(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_radius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          // A minimum, not a cap: a larger system font grows the bar rather
          // than clipping the labels.
          constraints: const BoxConstraints(minHeight: _height),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
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
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          destination.icon,
          size: AppBottomNav._iconSize,
          color: isActive ? Colors.white : AppBottomNav._inactive,
        ),
        const SizedBox(height: AppBottomNav._iconToLabel),
        Text(
          destination.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : AppBottomNav._inactive,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            height: 1.17,
            letterSpacing: 0,
          ),
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: isActive
          ? ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: AppBottomNav._gradient.createShader,
              child: content,
            )
          : content,
    );
  }
}
