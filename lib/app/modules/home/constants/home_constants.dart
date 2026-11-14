import 'package:flutter/material.dart';

abstract final class HomeStrings {
  static const logoLight = 'trip';
  static const logoBold = 'triva';
  static const searchHint = 'Search';
  static const datePlaceholder = 'dd / mm /yyyy';
  static const priceRange = 'Price Range';
  static const bookNow = 'Book Now';
  static const viewAll = 'View all';

  static const mostPopular = 'Most Popular';
  static const nearBy = 'Near By';
  static const freshUpRooms = 'Fresh up rooms';
  static const newAdventure = 'New Adventure';

  static const categoryStay = 'Stay';
  static const categoryHouseBoat = 'House Boat';
  static const categoryAdventure = 'Adventure';

  static const filter = 'Filter';
  static const calendar = 'Calender';
  static const above = 'Above';
  static const below = 'Below';
  static const rupee = '₹';

  static const priceOptions = [
    '₹500 Below',
    '₹500 - ₹1000',
    '₹1000 - ₹5000',
    '₹5000 Above',
  ];

  static const capacityOptions = [
    '30 person capacity',
    '20 person capacity',
    '10 person capacity',
    'couple boat',
  ];

  static const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];
  static const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const wishlistFailed = 'Could not update wishlist';
  static const emptySection = 'Nothing here yet';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class HomeDurations {
  static const snackbar = Duration(seconds: 2);
  static const bannerAutoSlide = Duration(seconds: 4);
  static const bannerTransition = Duration(milliseconds: 450);
}

abstract final class HomeSizes {
  static const pagePadding = 20.0;

  static const logoFontSize = 24.0;
  static const bellSize = 22.0;
  static const logoToSearch = 14.0;

  static const searchHeight = 60.0;
  static const searchRadius = 30.0;
  static const searchIconSize = 18.0;
  static const searchIconToLabel = 12.0;
  static const searchToCategories = 8.0;

  static const categoryHeight = 89.0;
  static const categoryIconSize = 44.0;
  static const categoryIconToLabel = 6.0;
  static const categoryRadius = 20.0;

  static const bannerHeight = 250.0;
  static const bannerRadius = 30.0;
  static const bannerGap = 20.0;
  static const bannerLabelInset = 30.0;
  static const bookNowWidth = 115.0;
  static const bookNowHeight = 39.0;
  static const bookNowRadius = 14.0;

  static const bannerToDots = 8.0;
  static const dotGap = 13.0;
  static const dotSize = 10.0;
  static const activeDotSize = 14.0;
  static const dotsToFilters = 40.0;

  static const filterHeight = 40.0;
  static const filterRadius = 20.0;
  static const filterGap = 8.0;
  static const filterIconSize = 18.0;
  static const filterIconToLabel = 8.0;
  static const filtersToSections = 30.0;

  /// Pop-ups under the filter row.
  static const panelGap = 10.0;
  static const panelRadius = 20.0;
  static const panelPadding = 20.0;
  static const panelCloseSize = 22.0;
  static const panelOptionGap = 22.0;
  static const filterPanelWidth = 250.0;
  static const pricePanelWidth = 270.0;
  static const calendarPanelWidth = 360.0;
  static const calendarHeaderHeight = 50.0;
  static const calendarCellHeight = 40.0;
  static const priceFieldHeight = 36.0;
  static const priceFieldRadius = 8.0;

  /// Inset of the overlays on the banner. The listing card's own spacing
  /// tokens live with the card, in `widgets/listing/listing_card_theme.dart`.
  static const overlayInset = 10.0;

  static const sectionTitleToBody = 20.0;
  static const sectionGap = 26.0;
  static const dividerTopPadding = 20.0;

  static const freshRadius = 30.0;
  static const freshTopPadding = 22.0;
  static const freshBottomPadding = 31.0;
  static const freshInnerPadding = 20.0;
  static const freshRowGap = 46.0;
  static const freshToViewAll = 20.0;
}

abstract final class HomePalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;
  static const border = Color(0xFFD9D9D9);
  static const divider = Color(0xFFD9D9D9);
  static const hintText = Color(0xFF727783);
  static const locationText = Color(0xFF7B7B7B);
  static const strikeText = Color(0xFF999999);
  static const categoryInactive = Color(0xFF2D2C2C);
  static const imagePlaceholder = Color(0xFFD9D9D9);
  static const dotStart = Color(0xFFD0D0D0);
  static const dotEnd = Color(0xFF999999);
  static const panelStrip = Color(0xFFF2F2F2);
  static const priceField = Color(0xFFD9D9D9);
  static const mutedDay = Color(0xFFC4C4C4);
}

abstract final class HomeGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [HomePalette.green, HomePalette.blue],
  );

  /// Reversed brand gradient used behind the active category chip.
  static const categoryBrand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [HomePalette.blue, HomePalette.green],
  );

  /// White veil so the active category chip fades to white at the bottom.
  static LinearGradient categoryWhiteFade() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        HomePalette.white.withValues(alpha: 0),
        HomePalette.white.withValues(alpha: 0.7),
        HomePalette.white,
        HomePalette.white,
      ],
      stops: const [0, 0.1779, 0.7163, 1],
    );
  }

  /// White veil over the brand gradient on the "Fresh up rooms" panel.
  static LinearGradient freshWhiteFade() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        HomePalette.white.withValues(alpha: 0.82),
        HomePalette.white,
        HomePalette.white,
      ],
      stops: const [0, 0.1827, 1],
    );
  }

  static const inactiveDot = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [HomePalette.dotStart, HomePalette.dotEnd],
  );
}

abstract final class HomeShadows {
  static final search = [
    BoxShadow(
      color: HomePalette.black.withValues(alpha: 0.2),
      blurRadius: 13,
    ),
  ];

  static final bookNow = [
    BoxShadow(
      color: HomePalette.black.withValues(alpha: 0.3),
      blurRadius: 24,
    ),
  ];

  static final freshPanel = [
    BoxShadow(
      color: HomePalette.black.withValues(alpha: 0.25),
      blurRadius: 10,
    ),
  ];
}

abstract final class HomeStyle {
  static const logo = TextStyle(
    color: HomePalette.white,
    fontSize: HomeSizes.logoFontSize,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0,
  );

  static const searchHint = TextStyle(
    color: HomePalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const categoryActive = TextStyle(
    color: HomePalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
    letterSpacing: 0,
  );

  static const categoryInactive = TextStyle(
    color: HomePalette.categoryInactive,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.17,
    letterSpacing: 0,
  );

  static const bannerTitle = TextStyle(
    color: HomePalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1.17,
    letterSpacing: 0,
  );

  static const bookNow = TextStyle(
    color: HomePalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1.17,
    letterSpacing: 0,
  );

  static const filterLabel = TextStyle(
    color: HomePalette.hintText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const sectionTitle = TextStyle(
    color: HomePalette.black,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.18,
    letterSpacing: 0,
  );

  static const viewAll = TextStyle(
    color: HomePalette.blue,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.18,
    letterSpacing: 0,
    decoration: TextDecoration.underline,
    decorationColor: HomePalette.blue,
  );

  static const filterLabelActive = TextStyle(
    color: HomePalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const panelTitle = TextStyle(
    color: HomePalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const panelTitleSmall = TextStyle(
    color: HomePalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
  );

  static const panelOption = TextStyle(
    color: HomePalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const panelOptionSelected = TextStyle(
    color: HomePalette.green,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
  );

  static const calendarMonth = TextStyle(
    color: HomePalette.green,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const calendarWeekday = TextStyle(
    color: HomePalette.green,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.17,
  );

  static const calendarDay = TextStyle(
    color: HomePalette.black,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.17,
  );
}
