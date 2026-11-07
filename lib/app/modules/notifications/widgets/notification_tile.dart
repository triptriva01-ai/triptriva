import 'package:flutter/material.dart';

import '../../../data/models/app_notification.dart';
import '../constants/notifications_constants.dart';

/// One notification row: icon tile and title, then either a message or an
/// offer banner, then the relative time.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _IconTile(kind: notification.kind),
              const SizedBox(width: NotificationsSizes.iconToTitle),
              // Takes the rest of the row so a long title ellipsises rather
              // than pushing past the edge of the screen.
              Expanded(
                child: Text(
                  notification.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: NotificationsStyle.itemTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: NotificationsSizes.titleToBody),
          // The body lines up under the title rather than under the icon.
          Padding(
            padding: const EdgeInsets.only(
              left: NotificationsSizes.bodyIndent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notification.hasImage)
                  _OfferBanner(imageUrl: notification.imageUrl)
                else if (notification.message.isNotEmpty)
                  Text(
                    notification.message,
                    style: NotificationsStyle.message,
                  ),
                if (notification.timeAgo.isNotEmpty) ...[
                  const SizedBox(height: NotificationsSizes.bodyToTime),
                  Text(
                    notification.timeAgo,
                    style: NotificationsStyle.time,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The rounded square badge on the left of every row.
class _IconTile extends StatelessWidget {
  const _IconTile({required this.kind});

  final NotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (kind) {
      NotificationKind.booking => (
          Icons.event_available_outlined,
          NotificationsPalette.tileGreen,
        ),
      NotificationKind.payment => (
          Icons.check_circle,
          NotificationsPalette.paid,
        ),
      NotificationKind.offer => (
          Icons.local_offer,
          NotificationsPalette.blue,
        ),
      NotificationKind.general => (
          Icons.notifications_none,
          NotificationsPalette.tileGreen,
        ),
    };

    return Container(
      width: NotificationsSizes.iconTileSize,
      height: NotificationsSizes.iconTileSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // The radial green, then a white veil at 80% over the top of it.
        gradient: NotificationsGradients.iconTile,
        borderRadius: BorderRadius.circular(
          NotificationsSizes.iconTileRadius,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        color: NotificationsPalette.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(
          NotificationsSizes.iconTileRadius,
        ),
        backgroundBlendMode: BlendMode.lighten,
      ),
      child: Icon(icon, size: NotificationsSizes.iconSize, color: color),
    );
  }
}

/// Offer rows carry a banner where other rows carry a message.
class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // A bounded box holding an image, never text — it cannot clip content.
    return ClipRRect(
      borderRadius: BorderRadius.circular(NotificationsSizes.bannerRadius),
      child: SizedBox(
        height: NotificationsSizes.bannerHeight,
        width: double.infinity,
        child: imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _BannerPlaceholder(),
              )
            : const _BannerPlaceholder(),
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: NotificationsPalette.placeholder,
      child: Center(
        child: Icon(
          Icons.local_offer_outlined,
          color: NotificationsPalette.white,
          size: 32,
        ),
      ),
    );
  }
}

/// Hairline between rows, fading to transparent at both ends.
class NotificationDivider extends StatelessWidget {
  const NotificationDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 2,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: NotificationsGradients.rule),
      ),
    );
  }
}
