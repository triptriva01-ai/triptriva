import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/notifications_constants.dart';
import '../controllers/notifications_controller.dart';

/// "All" / "Offers". The active tab's label carries the brand gradient.
class NotificationTabs extends StatelessWidget {
  const NotificationTabs({required this.controller, super.key});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedFilter.value;

      return Row(
        children: [
          // Equal shares rather than the Figma's fixed 187 dp, so the pair
          // always spans the page whatever its width.
          Expanded(
            child: _Tab(
              label: NotificationsStrings.tabAll,
              isActive: selected == NotificationFilter.all,
              onTap: () => controller.selectFilter(NotificationFilter.all),
            ),
          ),
          const SizedBox(width: NotificationsSizes.tabGap),
          Expanded(
            child: _Tab(
              label: NotificationsStrings.tabOffers,
              isActive: selected == NotificationFilter.offers,
              onTap: () => controller.selectFilter(NotificationFilter.offers),
            ),
          ),
        ],
      );
    });
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
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: isActive
          ? NotificationsStyle.tabActive
          : NotificationsStyle.tab,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        // A minimum, not a cap: a larger system font grows the pill rather
        // than clipping the label.
        constraints: const BoxConstraints(
          minHeight: NotificationsSizes.tabHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NotificationsPalette.white,
          borderRadius: BorderRadius.circular(
            NotificationsSizes.tabRadius,
          ),
        ),
        child: isActive
            ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: NotificationsGradients.prime.createShader,
                child: text,
              )
            : text,
      ),
    );
  }
}
