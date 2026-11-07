import 'package:flutter/material.dart';

import '../../data/models/listing.dart';
import 'listing_card_theme.dart';

/// Listing card shared by Home and Wishlist: image with discount badge,
/// rating pill and wishlist heart, then location, title and pricing.
///
/// The card has no width of its own — it fills whatever its parent gives it,
/// so the same widget works in a two-column grid on a 320 dp phone and in a
/// wider one on a tablet.
class ListingCard extends StatelessWidget {
  const ListingCard({
    required this.listing,
    required this.onTap,
    required this.onWishlistTap,
    super.key,
  });

  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardImage(listing: listing, onWishlistTap: onWishlistTap),
          const SizedBox(height: ListingCardSizes.gap),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: ListingCardSizes.pinSize,
                color: ListingCardPalette.pinGreen,
              ),
              const SizedBox(width: ListingCardSizes.pinToLabel),
              Flexible(
                child: Text(
                  listing.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ListingCardStyle.location,
                ),
              ),
            ],
          ),
          const SizedBox(height: ListingCardSizes.gap),
          Text(
            listing.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ListingCardStyle.title,
          ),
          const SizedBox(height: ListingCardSizes.gap),
          // Wraps rather than overflowing: at a large system font the struck
          // original price drops to its own line instead of being clipped.
          Wrap(
            spacing: ListingCardSizes.priceGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                formatAmount(listing.price),
                style: ListingCardStyle.price,
              ),
              if (listing.originalPrice != null)
                Text(
                  formatAmount(listing.originalPrice!),
                  style: ListingCardStyle.originalPrice,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// `1200` renders as `₹1200/-`, `99.5` as `₹99.50/-`.
  static String formatAmount(double value) {
    final amount = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '₹$amount/-';
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.listing, required this.onWishlistTap});

  final Listing listing;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ListingCardSizes.imageHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ListingCardSizes.imageRadius,
              ),
              child: _ListingImage(imageUrl: listing.imageUrl),
            ),
          ),
          if (listing.hasDiscount)
            Positioned(top: 0, left: 0, child: _DiscountBadge(listing: listing)),
          Positioned(
            top: ListingCardSizes.overlayInset,
            right: ListingCardSizes.overlayInset,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onWishlistTap,
              child: Icon(
                listing.isWishlisted ? Icons.favorite : Icons.favorite_border,
                size: ListingCardSizes.heartSize,
                color: ListingCardPalette.white,
              ),
            ),
          ),
          Positioned(
            left: ListingCardSizes.overlayInset,
            bottom: ListingCardSizes.overlayInset,
            child: _RatingPill(rating: listing.rating),
          ),
        ],
      ),
    );
  }
}

/// Falls back to a neutral placeholder while the backend has no images.
class _ListingImage extends StatelessWidget {
  const _ListingImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const ColoredBox(
        color: ListingCardPalette.imagePlaceholder,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: ListingCardPalette.white,
            size: ListingCardSizes.placeholderIconSize,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: ListingCardPalette.imagePlaceholder,
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      // A minimum rather than a fixed size: the badge grows with the system
      // font instead of clipping "14%".
      constraints: const BoxConstraints(
        minWidth: ListingCardSizes.badgeWidth,
        minHeight: ListingCardSizes.badgeHeight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: ListingCardPalette.discountGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ListingCardSizes.badgeRadius),
          bottomRight: Radius.circular(ListingCardSizes.badgeRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.south,
            size: ListingCardSizes.badgeIconSize,
            color: ListingCardPalette.white,
          ),
          const SizedBox(width: ListingCardSizes.badgeIconToLabel),
          Text('${listing.discountPercent}%', style: ListingCardStyle.badge),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ListingCardPalette.black,
        borderRadius: BorderRadius.circular(ListingCardSizes.ratingRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ListingCardSizes.ratingPaddingX,
          vertical: ListingCardSizes.ratingPaddingY,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: ListingCardSizes.starSize,
              color: ListingCardPalette.white,
            ),
            const SizedBox(width: ListingCardSizes.starToLabel),
            Text(rating.toStringAsFixed(1), style: ListingCardStyle.rating),
          ],
        ),
      ),
    );
  }
}
