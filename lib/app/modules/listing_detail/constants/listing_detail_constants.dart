import 'package:flutter/material.dart';

abstract final class ListingDetailStrings {
  static const facilities = 'Our Facilities';
  static const policies = 'Our Policies';
  static const location = 'Our Location';
  static const about = 'About';
  static const viewMore = 'View more';
  static const viewLess = 'View less';
  static const checkSlots = 'Check Slot Avaliability';

  static String reviews(int count) => '$count reviews';
  static String reviewTotal(int count) => '( $count )';

  static const filterAll = 'All';
  static const filterRecent = 'Recent';
  static const filterPositive = 'Positive';
  static const filterNegative = 'Negative';
  static const filterOld = 'Old';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class ListingDetailDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class ListingDetailSizes {
  static const pagePadding = 20.0;

  /// Hero photo. A bounded box holding an image, never text.
  static const heroHeight = 430.0;
  static const sheetRadius = 40.0;
  static const sheetOverlap = 40.0;

  static const circleButtonSize = 38.0;
  static const circleIconSize = 18.0;
  static const circleButtonGap = 16.0;
  static const headerInset = 20.0;

  static const dotSize = 12.0;
  static const activeDotWidth = 42.0;
  static const dotGap = 16.0;
  static const dotsBottomInset = 60.0;

  static const titleToAddress = 16.0;
  static const addressToMeta = 40.0;
  static const metaGap = 16.0;
  static const metaDotSize = 10.0;

  static const ratingBlockGap = 26.0;
  static const ratingDividerWidth = 2.0;
  static const ratingDividerHeight = 40.0;

  static const hostAvatarSize = 50.0;
  static const hostGap = 16.0;

  static const sectionGap = 40.0;
  static const bulletGap = 36.0;

  static const mapHeight = 220.0;
  static const mapRadius = 30.0;

  /// Lines of the About paragraph shown before "View more". A line count
  /// rather than a height, so the block grows with the system font instead of
  /// the text spilling out of a fixed box.
  static const aboutCollapsedLines = 4;
  static const aboutFadeHeight = 60.0;

  static const viewMoreHeight = 42.0;
  static const viewMoreRadius = 30.0;

  static const reviewFilterHeight = 42.0;
  static const reviewFilterRadius = 20.0;
  static const reviewFilterGap = 12.0;
  static const reviewCardWidth = 320.0;
  static const reviewCardRadius = 20.0;
  static const reviewAvatarSize = 40.0;
  static const reviewStarSize = 13.0;

  /// Card width in the "Near By" rail, from the Figma export.
  static const nearbyCardWidth = 157.0;
  static const nearbyGap = 16.0;

  static const bottomBarRadius = 40.0;
  static const bottomBarHeight = 60.0;
  static const listBottomPadding = 40.0;
}

abstract final class ListingDetailPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;

  static const muted = Color(0xFF7B7B7B);
  static const body = Color(0xFF505050);
  static const rule = Color(0xFFF0F0F0);
  static const divider = Color(0xFF8F8F8F);
  static const mapBorder = Color(0xFFD5D5D5);
  static const placeholder = Color(0xFF3F3F3F);

  /// "Great" — the rating word.
  static const ratingWord = Color(0xFFFFD400);

  static const struck = Color(0xFF999999);
  static const cancellation = Color(0xFFFF4800);
  static const disabled = Color(0xFFBABABA);
}

abstract final class ListingDetailGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [ListingDetailPalette.green, ListingDetailPalette.blue],
  );

  /// White veil that fades the tail of the collapsed About paragraph.
  static const aboutFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00FFFFFF), ListingDetailPalette.white],
  );

  /// The brand gradient at 20%, behind the cancellation note.
  static LinearGradient cancellationWash() {
    return LinearGradient(
      colors: [
        ListingDetailPalette.green.withValues(alpha: 0.2),
        ListingDetailPalette.blue.withValues(alpha: 0.2),
      ],
    );
  }
}

abstract final class ListingDetailStyle {
  /// Figma uses Roboto Black for the listing name.
  static const name = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    height: 1.15,
  );

  static const address = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 20,
    height: 1.15,
  );

  static const meta = TextStyle(
    color: ListingDetailPalette.muted,
    fontSize: 20,
    height: 1.15,
  );

  static const score = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  static const ratingWord = TextStyle(
    color: ListingDetailPalette.ratingWord,
    fontSize: 30,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const ratingCaption = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 18,
    height: 1.17,
  );

  static const hostName = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 20,
    height: 1.15,
  );

  static const hostRole = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 16,
    height: 1.19,
  );

  static const sectionTitle = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const coordinates = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 20,
    height: 1.15,
  );

  static const aboutBody = TextStyle(
    color: ListingDetailPalette.body,
    fontSize: 20,
    height: 1.5,
  );

  static const viewMore = TextStyle(
    color: ListingDetailPalette.body,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  static const bigScore = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 60,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const reviewCount = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 20,
    height: 1.15,
  );

  static const filterActive = TextStyle(
    color: ListingDetailPalette.black,
    fontSize: 20,
    height: 1.15,
  );

  static const filterInactive = TextStyle(
    color: ListingDetailPalette.muted,
    fontSize: 20,
    height: 1.15,
  );

  static const reviewBody = TextStyle(
    color: ListingDetailPalette.body,
    fontSize: 20,
    height: 1.5,
  );

  static const cta = TextStyle(
    color: ListingDetailPalette.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.15,
  );

  static const cancellation = TextStyle(
    color: ListingDetailPalette.cancellation,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );
}
