import 'package:flutter/material.dart';

abstract final class BookingStrings {
  static const selectDate = 'Select a date';
  static const selectSlot = 'Select a slot';
  static const date = 'Date';
  static const numberOfPeople = 'Number of people';

  static const checkIn = 'Check in date';
  static const checkOut = 'Check out date';

  static const reserve = 'Reserve';
  static const bookNow = 'Book now';
  static const viewLess = 'View less';

  static const legendFull = 'Full Filled';
  static const legendOffer = 'offer';
  static const legendSeason = 'Season';

  static const dayTripCharge = 'Day Trip Charge';
  static const totalDays = 'Total Days';
  static const couponDiscount = 'Coupon Discount';
  static const youHaveSaved = 'You have saved';
  static const toPay = 'To pay';

  static String forSlot(String slot) => 'For $slot';
  static String times(int count) => 'x$count';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class BookingDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class BookingSizes {
  static const pagePadding = 20.0;

  /// Hero photo behind the top of the sheet.
  static const heroHeight = 430.0;
  static const sheetRadius = 40.0;

  static const circleButtonSize = 38.0;
  static const circleIconSize = 18.0;
  static const circleButtonGap = 16.0;

  static const headingIconSize = 20.0;
  static const headingGap = 10.0;
  static const headingToBody = 30.0;

  static const legendToCalendar = 30.0;

  /// Minimums, not fixed sizes: the rows grow with the system font.
  static const slotRowHeight = 50.0;
  static const slotRowRadius = 60.0;
  static const slotRowGap = 12.0;
  static const slotDividerWidth = 1.0;
  static const slotDividerHeight = 30.0;
  static const slotLabelGap = 20.0;

  static const dateCardHeight = 50.0;
  static const dateCardRadius = 60.0;
  static const dateCardGap = 12.0;
  static const dateRangeGap = 16.0;

  static const paxCardRadius = 30.0;
  static const paxCardMinHeight = 86.0;
  static const paxCardToSlider = 25.0;
  static const sliderTrackHeight = 6.0;
  static const sliderThumbRadius = 12.0;

  static const sectionGap = 30.0;
  static const bodyBottomPadding = 40.0;

  static const billSheetRadius = 60.0;
  static const billRowGap = 14.0;
}

abstract final class BookingPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;

  static const border = Color(0xFFDFDFDF);
  static const track = Color(0xFFD9D9D9);
  static const trackBorder = Color(0xFFBABABA);
  static const muted = Color(0xFF767676);
  static const meta = Color(0xFF727783);
  static const struck = Color(0xFF777777);
  static const saving = Color(0xFF0CA201);
  static const placeholder = Color(0xFF3F3F3F);

  /// Calendar key.
  static const full = Color(0xFFFF0000);
  static const offer = Color(0xFF1F7A62);
  static const season = Color(0xFF2D9CDB);
}

abstract final class BookingGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [BookingPalette.green, BookingPalette.blue],
  );

  /// Hairline that fades out towards both ends.
  static const rule = LinearGradient(
    colors: [Color(0x00000000), Color(0xFFB5B5B5), Color(0x00000000)],
  );
}

abstract final class BookingStyle {
  static const heading = TextStyle(
    color: BookingPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  static const slotLabel = TextStyle(
    color: BookingPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
  );

  static const dateLabel = TextStyle(
    color: BookingPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
  );

  static const paxValue = TextStyle(
    color: BookingPalette.black,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const sliderBound = TextStyle(
    color: BookingPalette.muted,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.19,
  );

  /// Colour is replaced by the brand gradient shader.
  static const sliderValue = TextStyle(
    color: BookingPalette.white,
    fontSize: 16,
    fontWeight: FontWeight.w900,
    height: 1.19,
  );

  static const billLabel = TextStyle(
    color: BookingPalette.meta,
    fontSize: 16,
    height: 1.06,
    letterSpacing: -0.16,
  );

  static const billValue = TextStyle(
    color: BookingPalette.meta,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const billStruck = TextStyle(
    color: BookingPalette.struck,
    fontSize: 16,
    height: 1.2,
    decoration: TextDecoration.lineThrough,
    decorationColor: BookingPalette.struck,
  );

  static const billSaving = TextStyle(
    color: BookingPalette.saving,
    fontSize: 16,
    height: 1.06,
    letterSpacing: -0.16,
  );

  static const billSavingValue = TextStyle(
    color: BookingPalette.saving,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const billTotal = TextStyle(
    color: BookingPalette.meta,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const viewLess = TextStyle(
    color: BookingPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.19,
  );
}
