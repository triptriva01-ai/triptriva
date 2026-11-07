import 'package:flutter/material.dart';

abstract final class NotificationsStrings {
  static const title = 'Notification';
  static const tabAll = 'All';
  static const tabOffers = 'Offers';
  static const empty = 'Nothing new right now.';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class NotificationsDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class NotificationsSizes {
  static const pagePadding = 20.0;

  static const headerTop = 18.0;
  static const backButtonSize = 38.0;
  static const backIconSize = 18.0;
  static const backToTitle = 16.0;
  static const headerToTabs = 32.0;

  /// Minimums, not fixed sizes: the tabs grow with the system font.
  static const tabHeight = 39.0;
  static const tabRadius = 20.0;
  static const tabGap = 16.0;
  static const tabsToList = 30.0;

  static const iconTileSize = 46.0;
  static const iconTileRadius = 12.0;
  static const iconSize = 30.0;

  /// Gap between the icon tile and the title, and the matching indent that
  /// lines the message up under the title.
  static const iconToTitle = 13.0;
  static const bodyIndent = iconTileSize + iconToTitle;

  static const titleToBody = 12.0;
  static const bodyToTime = 16.0;
  static const itemGap = 20.0;

  static const bannerHeight = 200.0;
  static const bannerRadius = 20.0;

  static const listBottomPadding = 40.0;
}

abstract final class NotificationsPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const tileGreen = Color(0xFF1F7A62);
  static const paid = Color(0xFF009F0B);

  static const white = Colors.white;
  static const black = Colors.black;
  static const body = Color(0xFF000000);
  static const time = Color(0xFF8C8C8C);
  static const placeholder = Color(0xFFD9D9D9);
}

abstract final class NotificationsGradients {
  /// The "prime g" brand gradient, used as a shader on the active tab.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [NotificationsPalette.green, NotificationsPalette.blue],
  );

  /// Icon tile: a radial green glow almost entirely washed out by white.
  static const iconTile = RadialGradient(
    colors: [Color(0xFFFFFFFF), NotificationsPalette.tileGreen],
  );

  /// Hairline between rows, fading out towards both ends.
  static const rule = LinearGradient(
    stops: [0.1, 0.5, 0.9],
    colors: [Color(0x00000000), Color(0xFFB5B5B5), Color(0x00000000)],
  );
}

abstract final class NotificationsStyle {
  static const title = TextStyle(
    color: NotificationsPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: 0,
  );

  static const tab = TextStyle(
    color: NotificationsPalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
    letterSpacing: 0,
  );

  /// Colour is replaced by the brand gradient shader on the active tab.
  static const tabActive = TextStyle(
    color: NotificationsPalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
    letterSpacing: 0,
  );

  static const itemTitle = TextStyle(
    color: NotificationsPalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: 0,
  );

  static const message = TextStyle(
    color: NotificationsPalette.body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const time = TextStyle(
    color: NotificationsPalette.time,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );
}
