import 'package:flutter/material.dart';

abstract final class WishlistStrings {
  static const title = 'Wishlist';
  static const searchHint = 'Search';

  /// End-of-list marker, and the whole message when nothing is saved.
  static const noMoreWishes = 'No More Wishes';
  static const emptyHint =
      'Tap the heart on a listing to keep it here for later.';

  static const categoryStay = 'Stay';
  static const categoryHouseBoat = 'House Boat';
  static const categoryAdventure = 'Adventure';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class WishlistDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class WishlistSizes {
  static const pagePadding = 20.0;

  static const headerTop = 18.0;
  static const backButtonSize = 38.0;
  static const backIconSize = 18.0;
  static const backToTitle = 12.0;
  static const headerToFilters = 26.0;

  /// Minimums, not fixed sizes: the pills grow with the system font rather
  /// than clipping their labels.
  static const filterHeight = 40.0;
  static const filterRadius = 20.0;
  static const filterGap = 16.0;
  static const filterPaddingX = 16.0;
  static const filterPaddingY = 8.0;
  static const filterIconSize = 16.0;
  static const filterIconGap = 8.0;
  static const caretSize = 20.0;

  static const filtersToGrid = 30.0;

  static const gridRowGap = 43.0;
  static const gridColumnGap = 16.0;

  static const gridToFooter = 40.0;
  static const dividerToLabel = 30.0;
  static const illustrationSize = 180.0;
  static const listBottomPadding = 40.0;
}

abstract final class WishlistPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;
  static const border = Color(0xFFD9D9D9);
  static const divider = Color(0xFFD9D9D9);
  static const muted = Color(0xFF7B7B7B);
  static const hintText = Color(0xFF727783);
}

abstract final class WishlistGradients {
  /// The "prime g" brand gradient, used as a shader on "No More Wishes".
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [WishlistPalette.green, WishlistPalette.blue],
  );
}

abstract final class WishlistShadows {
  static final filterPill = [
    BoxShadow(
      color: WishlistPalette.black.withValues(alpha: 0.1),
      blurRadius: 8,
    ),
  ];
}

abstract final class WishlistStyle {
  static const title = TextStyle(
    color: WishlistPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: 0,
  );

  static const filterLabel = TextStyle(
    color: WishlistPalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
    letterSpacing: 0,
  );

  static const searchHint = TextStyle(
    color: WishlistPalette.hintText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  /// Colour is replaced by the brand gradient shader.
  static const noMoreWishes = TextStyle(
    color: WishlistPalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.21,
    letterSpacing: 0,
  );

  static const emptyHint = TextStyle(
    color: WishlistPalette.muted,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );
}
