import 'package:flutter/material.dart';

import '../../../data/models/listing_detail.dart';
import '../constants/listing_detail_constants.dart';
import 'star_row.dart';

/// Name, address, the stay counts (or tagline), and the rating block.
class ListingSummary extends StatelessWidget {
  const ListingSummary({required this.detail, super.key});

  final ListingDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          detail.name,
          textAlign: TextAlign.center,
          style: ListingDetailStyle.name,
        ),
        if (detail.address.isNotEmpty) ...[
          const SizedBox(height: ListingDetailSizes.titleToAddress),
          Text(
            detail.address,
            textAlign: TextAlign.center,
            style: ListingDetailStyle.address,
          ),
        ],
        const SizedBox(height: ListingDetailSizes.addressToMeta),
        if (detail.hasStayCounts)
          _MetaRow(parts: detail.stayCounts)
        else if (detail.tagline.isNotEmpty)
          Text(
            detail.tagline,
            textAlign: TextAlign.center,
            style: ListingDetailStyle.meta,
          ),
        const SizedBox(height: ListingDetailSizes.addressToMeta),
        _RatingBlock(detail: detail),
      ],
    );
  }
}

/// "3 rooms · 3 bathroom · 6 bed", with a dot between each part.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    // Wrap rather than Row: on a narrow phone, or at a large system font, the
    // parts fall onto a second line instead of overflowing.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: ListingDetailSizes.metaGap,
      runSpacing: 8,
      children: [
        for (var index = 0; index < parts.length; index++) ...[
          if (index > 0)
            Container(
              width: ListingDetailSizes.metaDotSize,
              height: ListingDetailSizes.metaDotSize,
              decoration: const BoxDecoration(
                color: ListingDetailPalette.black,
                shape: BoxShape.circle,
              ),
            ),
          Text(parts[index], style: ListingDetailStyle.meta),
        ],
      ],
    );
  }
}

/// Score and stars | the rating word | the review count, divided by rules.
class _RatingBlock extends StatelessWidget {
  const _RatingBlock({required this.detail});

  final ListingDetail detail;

  @override
  Widget build(BuildContext context) {
    // Wrap so the three columns stack instead of overflowing when the system
    // font grows; the dividers travel with them.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: ListingDetailSizes.ratingBlockGap,
      runSpacing: 16,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              detail.rating.toStringAsFixed(1),
              style: ListingDetailStyle.score,
            ),
            const SizedBox(height: 8),
            StarRow(rating: detail.rating),
          ],
        ),
        if (detail.ratingLabel.isNotEmpty) ...[
          const _Divider(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                detail.ratingLabel,
                textAlign: TextAlign.center,
                style: ListingDetailStyle.ratingWord,
              ),
              if (detail.ratingCaption.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  detail.ratingCaption,
                  style: ListingDetailStyle.ratingCaption,
                ),
              ],
            ],
          ),
        ],
        const _Divider(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${detail.reviewCount}',
              style: ListingDetailStyle.score,
            ),
            const SizedBox(height: 8),
            const Text('reviews', style: ListingDetailStyle.ratingCaption),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ListingDetailSizes.ratingDividerWidth,
      height: ListingDetailSizes.ratingDividerHeight,
      decoration: BoxDecoration(
        color: ListingDetailPalette.divider,
        borderRadius: BorderRadius.circular(40),
      ),
    );
  }
}

/// The host's avatar, name and role.
class HostRow extends StatelessWidget {
  const HostRow({required this.host, super.key});

  final ListingHost host;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: ListingDetailSizes.hostAvatarSize,
            height: ListingDetailSizes.hostAvatarSize,
            child: host.avatarUrl.isEmpty
                ? const ColoredBox(
                    color: ListingDetailPalette.placeholder,
                    child: Icon(
                      Icons.person,
                      color: ListingDetailPalette.white,
                    ),
                  )
                : Image.network(
                    host.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: ListingDetailPalette.placeholder,
                      child: Icon(
                        Icons.person,
                        color: ListingDetailPalette.white,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: ListingDetailSizes.hostGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                host.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ListingDetailStyle.hostName,
              ),
              const SizedBox(height: 11),
              Text(host.role, style: ListingDetailStyle.hostRole),
            ],
          ),
        ),
      ],
    );
  }
}
