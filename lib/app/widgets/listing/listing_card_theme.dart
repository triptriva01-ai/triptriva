import 'package:flutter/material.dart';

/// Design tokens for [ListingCard] and [ListingGrid].
///
/// The card appears on Home and on Wishlist, so it owns its tokens here rather
/// than borrowing them from either module's constants file.
abstract final class ListingCardSizes {
  /// Height of the photo. A fixed box is safe here: it holds an image and a
  /// few overlays, never text that could grow past it.
  static const imageHeight = 180.0;
  static const imageRadius = 20.0;

  /// Vertical rhythm between the photo, location, title and price rows.
  static const gap = 12.0;

  /// Default spacing between cards in a grid.
  static const columnGap = 16.0;
  static const rowGap = 40.0;

  static const badgeWidth = 59.0;
  static const badgeHeight = 35.0;
  static const badgeRadius = 20.0;
  static const badgeIconSize = 11.0;
  static const badgeIconToLabel = 3.0;

  /// Inset of the heart and the rating pill from the photo's edges.
  static const overlayInset = 10.0;
  static const heartSize = 24.0;

  static const ratingRadius = 23.0;
  static const ratingPaddingX = 8.0;
  static const ratingPaddingY = 4.0;
  static const starSize = 13.0;
  static const starToLabel = 3.0;

  static const pinSize = 12.0;
  static const pinToLabel = 6.0;

  static const priceGap = 8.0;

  static const placeholderIconSize = 32.0;
}

abstract final class ListingCardPalette {
  static const white = Colors.white;
  static const black = Colors.black;
  static const pinGreen = Color(0xFF1F7A62);
  static const discountGreen = Color(0xFF009F0B);
  static const locationText = Color(0xFF7B7B7B);
  static const strikeText = Color(0xFF999999);
  static const imagePlaceholder = Color(0xFFD9D9D9);
}

abstract final class ListingCardStyle {
  static const badge = TextStyle(
    color: ListingCardPalette.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const rating = TextStyle(
    color: ListingCardPalette.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const location = TextStyle(
    color: ListingCardPalette.locationText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const title = TextStyle(
    color: ListingCardPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const price = TextStyle(
    color: ListingCardPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.19,
    letterSpacing: 0,
  );

  static const originalPrice = TextStyle(
    color: ListingCardPalette.strikeText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
    decoration: TextDecoration.lineThrough,
    decorationColor: ListingCardPalette.strikeText,
  );
}
