import 'package:flutter/material.dart';

abstract final class ReservationsStrings {
  static const title = 'My Bookings';
  static const searchHint = 'Search';
  static const tabAll = 'All';
  static const tabBooked = 'Booked';
  static const tabCompleted = 'Completed';
  static const bookingIdPrefix = 'Booking ID : ';
  static const emptyMessage = 'No bookings to show yet.';

  static String people(int count) => '$count People';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class ReservationsDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class ReservationsSizes {
  static const pagePadding = 20.0;

  static const headerHeight = 180.0;
  static const headerRadius = 40.0;
  static const titleTop = 18.0;
  static const titleToTabs = 34.0;
  static const tabToUnderline = 12.0;
  static const underlineWidth = 71.0;
  static const underlineHeight = 6.0;
  static const underlineRadius = 30.0;

  static const searchHeight = 40.0;
  static const searchRadius = 20.0;
  static const searchIconSize = 18.0;
  static const searchIconToLabel = 10.0;
  static const headerToSearch = 15.0;
  static const searchToList = 20.0;

  static const cardRadius = 20.0;
  static const cardPadding = 16.0;
  static const cardGap = 16.0;
  static const groupLabelToCards = 20.0;
  static const thumbSize = 72.0;
  static const thumbRadius = 12.0;
  static const thumbIconSize = 36.0;
  static const thumbToDetails = 10.0;
  static const detailGap = 6.0;
  static const detailsToFooter = 14.0;
  static const chevronSize = 22.0;
  static const personIconSize = 12.0;
  static const personToLabel = 8.0;
  static const metaGap = 10.0;
  static const metaDividerWidth = 2.0;
  static const metaDividerHeight = 14.0;
  static const statusIconSize = 14.0;
  static const statusIconToLabel = 6.0;
  static const listBottomPadding = 24.0;
}

abstract final class ReservationsPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const thumbGreen = Color(0xFF1F7A62);
  static const white = Colors.white;
  static const black = Colors.black;
  static const border = Color(0xFFD9D9D9);
  static const divider = Color(0xFFD9D9D9);
  static const meta = Color(0xFF727783);
  static const inactiveTab = Color(0xFF7B7B7B);
  static const booked = Color(0xFF00D527);
  static const completed = Color(0xFF999999);
  static const bell = Color(0xFF7B7B7B);
}

abstract final class ReservationsGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [ReservationsPalette.green, ReservationsPalette.blue],
  );

  /// Pale radial wash behind each booking thumbnail.
  static const thumbBase = RadialGradient(
    colors: [ReservationsPalette.white, ReservationsPalette.thumbGreen],
  );

  /// Two stacked 80% white layers from the Figma export.
  static Color get thumbVeil =>
      ReservationsPalette.white.withValues(alpha: 0.9);
}

abstract final class ReservationsStyle {
  static const pageTitle = TextStyle(
    color: ReservationsPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: 0,
  );

  /// Colour is replaced by the gradient shader on the active tab.
  static const tabActive = TextStyle(
    color: ReservationsPalette.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0,
  );

  static const tabInactive = TextStyle(
    color: ReservationsPalette.inactiveTab,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: 0,
  );

  static const searchInput = TextStyle(
    color: ReservationsPalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
    letterSpacing: 0,
  );

  static const groupLabel = TextStyle(
    color: ReservationsPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const bookingId = TextStyle(
    color: ReservationsPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const bookingTitle = TextStyle(
    color: ReservationsPalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: 0,
  );

  static const people = TextStyle(
    color: ReservationsPalette.meta,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.14,
    letterSpacing: 0,
  );

  static const meta = TextStyle(
    color: ReservationsPalette.meta,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const booked = TextStyle(
    color: ReservationsPalette.booked,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const completed = TextStyle(
    color: ReservationsPalette.completed,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const empty = TextStyle(
    color: ReservationsPalette.meta,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );
}
