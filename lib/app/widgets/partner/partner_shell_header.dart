import 'package:flutter/material.dart';

import 'partner_theme.dart';

/// Gradient partner header: avatar + username on the left, notification bell
/// on the right, and folder-style tabs anchored to the bottom edge.
///
/// The height is intrinsic rather than fixed so a long partner name or a large
/// system font grows the header instead of overflowing it; [PartnerSizes
/// .headerContentHeight] acts as a minimum.
class PartnerShellHeader extends StatelessWidget {
  const PartnerShellHeader({
    required this.name,
    required this.onNotificationsTap,
    required this.onProfileTap,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  final String name;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  /// Empty on screens without sub-tabs, such as Revenue and My Business.
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return Container(
      // The gradient bleeds up behind the status bar.
      padding: EdgeInsets.only(
        top: statusBarHeight + PartnerSizes.headerTopSpacing,
      ),
      constraints: BoxConstraints(
        minHeight: statusBarHeight + PartnerSizes.headerContentHeight,
      ),
      decoration: BoxDecoration(
        gradient: PartnerGradients.header(),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(PartnerSizes.headerRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PartnerSizes.pagePadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onProfileTap,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: PartnerSizes.avatarSize,
                          color: PartnerPalette.avatarIcon,
                        ),
                        const SizedBox(width: PartnerSizes.avatarToName),
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PartnerStyle.partnerName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onNotificationsTap,
                  child: const Icon(
                    Icons.notifications,
                    size: PartnerSizes.bellSize,
                    color: PartnerPalette.black,
                  ),
                ),
              ],
            ),
          ),
          // Pushes the tabs to the bottom edge whenever the header is taller
          // than its content, without pinning either to a fixed offset.
          const SizedBox(height: PartnerSizes.headerTopSpacing),
          if (tabs.isNotEmpty)
            Center(
              child: ConstrainedBox(
                // Never wider than the screen, and inset on small phones.
                constraints: const BoxConstraints(
                  maxWidth: PartnerSizes.tabBarWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PartnerSizes.pagePadding,
                  ),
                  child: Row(
                    children: [
                      for (var index = 0; index < tabs.length; index++)
                        Expanded(
                          child: _Tab(
                            label: tabs[index],
                            isActive: selectedTab == index,
                            onTap: () => onTabSelected(index),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: PartnerSizes.tabBarHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? PartnerPalette.white : Colors.transparent,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(PartnerSizes.tabRadius),
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: isActive ? PartnerStyle.tabActive : PartnerStyle.tabInactive,
          ),
        ),
      ),
    );
  }
}
