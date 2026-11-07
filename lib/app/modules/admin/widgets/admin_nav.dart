import 'package:flutter/material.dart';

import '../constants/admin_constants.dart';

/// Admin shell navigation: Revenue / Activities / Payment / Users / Admin.
///
/// The active destination gets a gradient pill behind its icon and the brand
/// gradient on its label.
class AdminNav extends StatelessWidget {
  const AdminNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const revenue = 0;
  static const activities = 1;
  static const payment = 2;
  static const users = 3;
  static const profile = 4;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.show_chart, label: AdminStrings.revenue),
    (icon: Icons.kayaking, label: AdminStrings.activities),
    (icon: Icons.account_balance_wallet_outlined, label: AdminStrings.payment),
    (icon: Icons.groups_outlined, label: AdminStrings.users),
    (icon: Icons.admin_panel_settings_outlined, label: AdminStrings.admin),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminPalette.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AdminSizes.navRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AdminPalette.black.withValues(alpha: 0.25),
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
          constraints: const BoxConstraints(minHeight: AdminSizes.navHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Equal shares means five labels always fit, however narrow
                // the device.
                for (var index = 0; index < _items.length; index++)
                  Expanded(
                    child: _NavItem(
                      icon: _items[index].icon,
                      label: _items[index].label,
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
          Container(
            width: AdminSizes.navPillWidth,
            height: AdminSizes.navPillHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isActive ? AdminGradients.prime : null,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive
                  ? AdminPalette.white
                  : AdminPalette.navInactive,
            ),
          ),
          const SizedBox(height: 6),
          if (isActive)
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: AdminGradients.prime.createShader,
              child: _label(),
            )
          else
            _label(),
        ],
      ),
    );
  }

  Widget _label() {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: isActive ? AdminStyle.navLabelActive : AdminStyle.navLabel,
    );
  }
}
