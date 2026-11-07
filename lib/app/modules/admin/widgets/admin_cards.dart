import 'package:flutter/material.dart';

import '../../../data/models/admin_models.dart';
import '../constants/admin_constants.dart';
import '../controllers/admin_controller.dart';
import 'admin_shell.dart';

/// One of the two figures at the top of the Revenue dashboard.
class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    required this.label,
    required this.value,
    this.trendPercent,
    this.caption,
    super.key,
  });

  final String label;
  final String value;

  /// Month-on-month change; renders as a green "↑ 12%".
  final double? trendPercent;

  /// Shown instead of the trend, e.g. "1,248 Bookings".
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AdminStyle.statLabel,
          ),
          const SizedBox(height: 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AdminStyle.statValue),
          ),
          const SizedBox(height: 8),
          if (trendPercent != null)
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward,
                  size: 12,
                  color: AdminPalette.trend,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${trendPercent!.abs().round()}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AdminStyle.statTrend,
                  ),
                ),
              ],
            )
          else if (caption != null)
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AdminStyle.statCaption,
            ),
        ],
      ),
    );
  }
}

/// A booking row on the Revenue dashboard: photo, name, category, amount,
/// then the date range under a hairline.
class AdminBookingCard extends StatelessWidget {
  const AdminBookingCard({
    required this.booking,
    required this.onTap,
    super.key,
  });

  final AdminBooking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AdminCard(
        padding: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminAvatar(
                    imageUrl: booking.imageUrl,
                    size: AdminSizes.avatarSize,
                    radius: 20,
                  ),
                  const SizedBox(width: 8),
                  // Takes the slack so a long name ellipsises rather than
                  // pushing the amount off the edge.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          booking.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AdminStyle.cardTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.listingName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AdminStyle.cardCategory,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Scaled down rather than ellipsised: a truncated price
                  // ("₹18,50…") is worse than a slightly smaller one.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        AdminBaseController.formatRupees(booking.amount),
                        style: AdminStyle.cardAmount,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CategoryRow(category: booking.category),
              const SizedBox(height: 8),
              const _Hairline(),
              const SizedBox(height: 8),
              _MetaRow(text: booking.dateRange),
            ],
          ),
        ),
      ),
    );
  }
}

/// An activity awaiting approval, with the Reject / View details actions
/// under it when it is still pending.
class AdminActivityCard extends StatelessWidget {
  const AdminActivityCard({
    required this.activity,
    required this.onTap,
    this.onReject,
    super.key,
  });

  final AdminActivitySubmission activity;
  final VoidCallback onTap;

  /// Null on the Accepted tab, where there is nothing to reject.
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AdminCard(
            padding: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminAvatar(
                        imageUrl: activity.imageUrl,
                        size: AdminSizes.avatarSize,
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activity.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AdminStyle.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            _CategoryRow(category: activity.category),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AdminPalette.navInactive,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _OwnerRow(
                    name: activity.ownerName,
                    avatarUrl: activity.ownerAvatarUrl,
                  ),
                  const SizedBox(height: 8),
                  const _Hairline(),
                  const SizedBox(height: 8),
                  _MetaRow(text: activity.dateRange),
                ],
              ),
            ),
          ),
        ),
        if (onReject != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _OutlinedAction(
                  label: AdminStrings.reject,
                  style: AdminStyle.rejectAction,
                  onTap: onReject!,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OutlinedAction(
                  label: AdminStrings.viewDetails,
                  style: AdminStyle.linkAction,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        // A minimum, not a cap.
        constraints: const BoxConstraints(minHeight: 39),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AdminPalette.white,
          border: Border.all(color: AdminPalette.softBorder),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    if (category.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.sell_outlined, size: 12, color: AdminPalette.green),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AdminStyle.cardCategory,
          ),
        ),
      ],
    );
  }
}

class _OwnerRow extends StatelessWidget {
  const _OwnerRow({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminAvatar(
          imageUrl: avatarUrl,
          size: AdminSizes.tinyAvatarSize,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AdminStyle.cardOwner,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 11,
          color: AdminPalette.muted,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AdminStyle.cardMeta,
          ),
        ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(color: Color(0x1ABEC9C3)),
    );
  }
}
