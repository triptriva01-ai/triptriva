import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/listing_detail.dart';
import '../constants/listing_detail_constants.dart';
import '../controllers/listing_detail_controller.dart';
import 'star_row.dart';

/// The big score, the filter chips and the horizontal rail of review cards.
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    required this.detail,
    required this.controller,
    super.key,
  });

  final ListingDetail detail;
  final ListingDetailController controller;

  static const _filters = <(ReviewFilter, String)>[
    (ReviewFilter.all, ListingDetailStrings.filterAll),
    (ReviewFilter.recent, ListingDetailStrings.filterRecent),
    (ReviewFilter.positive, ListingDetailStrings.filterPositive),
    (ReviewFilter.negative, ListingDetailStrings.filterNegative),
    (ReviewFilter.old, ListingDetailStrings.filterOld),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                detail.rating.toStringAsFixed(1),
                style: ListingDetailStyle.bigScore,
              ),
              const SizedBox(height: 8),
              // The stars and the count share one Wrap so the count falls
              // onto the next line rather than overflowing.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  StarRow(rating: detail.rating, size: 21, gap: 12),
                  Text(
                    ListingDetailStrings.reviewTotal(detail.reviews.length),
                    style: ListingDetailStyle.reviewCount,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: ListingDetailSizes.sectionGap),
        Text(
          ListingDetailStrings.reviews(detail.reviewCount),
          style: ListingDetailStyle.reviewCount,
        ),
        const SizedBox(height: 20),
        Obx(() {
          final selected = controller.reviewFilter.value;

          // A horizontal scroller needs a bounded cross-axis size, so the
          // chips live in a Row inside a scroll view rather than a ListView.
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (filter, label) in _filters) ...[
                  _FilterChip(
                    label: label,
                    isActive: filter == selected,
                    onTap: () => controller.selectReviewFilter(filter),
                  ),
                  const SizedBox(width: ListingDetailSizes.reviewFilterGap),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: ListingDetailSizes.sectionGap),
        Obx(() {
          final reviews = controller.visibleReviews;
          if (reviews.isEmpty) {
            return const Text(
              'No reviews yet.',
              style: ListingDetailStyle.reviewBody,
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final review in reviews) ...[
                  _ReviewCard(review: review),
                  const SizedBox(width: ListingDetailSizes.reviewFilterGap),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
        // A minimum, not a cap.
        constraints: const BoxConstraints(
          minHeight: ListingDetailSizes.reviewFilterHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ListingDetailPalette.white,
          borderRadius: BorderRadius.circular(
            ListingDetailSizes.reviewFilterRadius,
          ),
          border: isActive
              ? Border.all(color: ListingDetailPalette.black)
              : null,
        ),
        child: Text(
          label,
          style: isActive
              ? ListingDetailStyle.filterActive
              : ListingDetailStyle.filterInactive,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ListingReview review;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // A fixed width in a horizontal rail is what makes the cards peek; the
      // height still grows with the text.
      width: ListingDetailSizes.reviewCardWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: ListingDetailPalette.white,
          borderRadius: BorderRadius.circular(
            ListingDetailSizes.reviewCardRadius,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: ListingDetailSizes.reviewAvatarSize,
                    height: ListingDetailSizes.reviewAvatarSize,
                    child: review.avatarUrl.isEmpty
                        ? const ColoredBox(
                            color: ListingDetailPalette.placeholder,
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: ListingDetailPalette.white,
                            ),
                          )
                        : Image.network(
                            review.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: ListingDetailPalette.placeholder,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        review.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ListingDetailStyle.hostName,
                      ),
                      const SizedBox(height: 11),
                      StarRow(rating: review.rating),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(review.comment, style: ListingDetailStyle.reviewBody),
          ],
        ),
      ),
    );
  }
}
