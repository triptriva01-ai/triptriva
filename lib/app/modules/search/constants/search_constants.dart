import 'package:flutter/material.dart';

abstract final class SearchStrings {
  static const hint = 'Search';
  static const nearby = 'Nearby';
  static const nearbySubtitle = 'Find what around you';
  static const available = 'Available';
  static const availableSubtitle = 'Available stay in this location';
  static const mostSearchedSubtitle = 'You have most searched locations';
  static const recentSearch = 'Recent Search';
  static const addDates = 'Add dates to search';
  static const addPeople = 'Add number of people';
  static const noMoreSearch = 'No more Search';

  static String stays(int count) => '$count+ Stays';
  static String people(int count) =>
      count == 1 ? '1 person' : '$count people';
  static const searchFor = 'Search for this place';
  static const noResults = 'No matches. Try another place or clear the filters.';
  static const removeRecent = 'Remove from recent searches?';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class SearchDurations {
  static const snackbar = Duration(seconds: 2);
  static const debounce = Duration(milliseconds: 300);
}

abstract final class SearchSizes {
  static const pagePadding = 20.0;

  static const fieldHeight = 60.0;
  static const fieldRadius = 30.0;
  static const fieldIconSize = 20.0;
  static const fieldIconGap = 12.0;
  static const clearIconSize = 18.0;
  static const fieldToCard = 10.0;

  static const cardRadius = 30.0;
  static const cardPadding = 20.0;
  static const rowGap = 30.0;

  static const tileSize = 50.0;
  static const tileRadius = 10.0;
  static const tileIconSize = 18.0;
  static const tileToText = 8.0;
  static const titleToSubtitle = 6.0;
  static const arrowSize = 22.0;

  static const cardToRecent = 28.0;
  static const recentTitleToRow = 12.0;
  static const recentSize = 80.0;
  static const recentIconSize = 28.0;
  static const recentGap = 16.0;
  static const recentImageToLabel = 10.0;

  static const recentToActions = 24.0;
  static const actionHeight = 60.0;
  static const actionRadius = 20.0;
  static const actionGap = 16.0;
  static const actionIconSize = 18.0;
}

abstract final class SearchPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;
  static const border = Color(0xFFD9D9D9);
  static const title = Color(0xFF2D2C2C);
  static const subtitle = Color(0xFF8F8F8F);
  static const clear = Color(0xFF9E9E9E);
  static const imagePlaceholder = Color(0xFFD9D9D9);
}

abstract final class SearchShadows {
  static final field = [
    BoxShadow(color: SearchPalette.black.withValues(alpha: 0.2), blurRadius: 13),
  ];

  static final card = [
    BoxShadow(color: SearchPalette.black.withValues(alpha: 0.2), blurRadius: 13),
  ];
}

abstract final class SearchStyle {
  static const input = TextStyle(
    color: SearchPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const rowTitle = TextStyle(
    color: SearchPalette.title,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const rowSubtitle = TextStyle(
    color: SearchPalette.subtitle,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.17,
  );

  static const sectionTitle = TextStyle(
    color: SearchPalette.title,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const recentLabel = TextStyle(
    color: SearchPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const action = TextStyle(
    color: SearchPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.19,
  );

  static const noMore = TextStyle(
    color: SearchPalette.subtitle,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.17,
  );
}
