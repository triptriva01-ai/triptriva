import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_page_header.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/partner_notifications_controller.dart';

/// Partner notification centre — booking, payment and offer updates.
class PartnerNotificationsView
    extends GetView<PartnerNotificationsController> {
  const PartnerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartnerPalette.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            PartnerPageHeader(
              title: 'Notification',
              onBack: controller.goBack,
            ),
            const SizedBox(height: 30),
            Obx(
              () => Row(
                children: [
                  for (var index = 0;
                      index < NotificationTab.values.length;
                      index++)
                    Expanded(
                      child: _Tab(
                        label: index == 0 ? 'All' : 'Offers',
                        isActive:
                            controller.selectedTab.value.index == index,
                        onTap: () => controller.selectTabAt(index),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = controller.visibleNotifications;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No notifications yet',
                      style: PartnerStyle.rowCaption,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const _Divider(),
                  itemBuilder: (context, index) =>
                      _NotificationTile(notification: items[index]),
                );
              }),
            ),
          ],
        ),
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
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isActive ? PartnerPalette.white : PartnerPalette.black,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 39,
        child: Center(
          child: isActive
              ? ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: PartnerGradients.prime.createShader,
                  child: text,
                )
              : text,
        ),
      ),
    );
  }
}

/// Hairline that fades out towards both edges, as in the Figma export.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          stops: [0.1, 0.5, 0.9],
          colors: [Color(0x00000000), Color(0xFFB5B5B5), Color(0x00000000)],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final PartnerNotification notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PartnerSizes.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      PartnerPalette.white,
                      PartnerPalette.headerGreen.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(notification.kind), size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  notification.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 59),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      notification.imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  )
                else
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: PartnerPalette.black,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  notification.age,
                  style: const TextStyle(
                    color: Color(0xFF8C8C8C),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PartnerNotificationKind kind) {
    return switch (kind) {
      PartnerNotificationKind.booking => Icons.event_available,
      PartnerNotificationKind.payment => Icons.check_circle,
      PartnerNotificationKind.offer => Icons.local_offer,
    };
  }
}
