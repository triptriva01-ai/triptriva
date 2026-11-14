import 'package:flutter/material.dart';

abstract final class BookingDetailStrings {
  static const statusBooked = 'Booked';
  static const statusCompleted = 'Completed';
  static const subtitle = 'booking completed now get ready for the big day';
  static const reminder = 'Reminder';
  static const bookingIdPrefix = 'Booking ID : ';
  static const copy = 'Copy';
  static const copied = 'Booking ID copied';

  /// The guest reads this code out to the partner at the venue.
  static const checkInCodePrefix = 'Check-in code';

  static const reviewPrompt = 'Let Know about your Adventure';
  static const writeReview = 'Write a Review';

  static const bookingDetails = 'Booking Details';
  static const getDirection = 'Get Direction';
  static const bookingDate = 'Booking Date';
  static const stayDetails = 'Stay Details';
  static const downloadInvoice = 'Download invoice';
  static String call(String name) => 'Call $name';

  static const totalPrice = 'Total Price';
  static const paymentDetails = 'Payment Details';
  static const viewYourBill = 'View Your Bill';

  static const facilities = 'Facilities';
  static const policies = 'Policies';
  static const about = 'About';
  static const viewMore = 'View more';
  static const viewLess = 'View less';
  static const goToPage = 'Go to page';

  static const noPartnerPhone = "The partner's number isn't available.";
  static const invoiceUnavailable =
      'The invoice is ready once the booking is paid.';
  static String invoiceSaved(String path) => 'Invoice saved to $path';
  static const reviewThanks = 'Thanks for your review!';
  static const cancelTitle = 'Cancel this booking?';
  static const cancelBody =
      "Any refund follows the listing's cancellation policy.";
  static const keepBooking = 'Keep booking';
  static const cancelBooking = 'Cancel booking';
  static const cancelled = 'Booking cancelled.';
  static String cancelledWithRefund(String amount) =>
      'Booking cancelled. $amount will be refunded.';
  static const reviewTitle = 'Rate your trip';
  static const reviewHint = 'Tell others what it was like';
  static const submit = 'Submit';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class BookingDetailDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class BookingDetailSizes {
  static const pagePadding = 20.0;

  static const backButtonSize = 38.0;
  static const backIconSize = 18.0;

  /// Gradient wash behind the top of the page.
  static const headerWashHeight = 289.0;

  static const cardRadius = 30.0;
  static const cardPadding = 22.0;
  static const cardGap = 30.0;
  static const sectionGap = 18.0;

  static const thumbLarge = 120.0;
  static const thumbSmall = 80.0;
  static const thumbRadius = 20.0;

  static const bulletSize = 10.0;
  static const bulletToLabel = 16.0;
  static const bulletGap = 36.0;

  /// Lines of the About paragraph shown before "View more". A line count
  /// rather than a height, so the block grows with the system font instead of
  /// the text spilling out of a fixed box.
  static const aboutCollapsedLines = 4;

  static const sheetRadius = 40.0;
}

abstract final class BookingDetailPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const greenDark = Color(0xFF1F7A62);

  static const white = Colors.white;
  static const black = Colors.black;

  static const subtitle = Color(0xFF444444);
  static const meta = Color(0xFF727783);
  static const muted = Color(0xFF7B7B7B);
  static const body = Color(0xFF505050);
  static const rule = Color(0xFFF0F0F0);
  static const inactiveCopy = Color(0xFF8D8D8D);
  static const struck = Color(0xFF777777);

  /// "You have saved" on the bill.
  static const saving = Color(0xFF0CA201);
}

abstract final class BookingDetailGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [BookingDetailPalette.green, BookingDetailPalette.blue],
  );

  /// Card background: the brand gradient almost entirely washed out by white,
  /// leaving a faint tint at the very top edge.
  static const cardWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.0001, 0.1827],
    colors: [
      Color(0x99FFFFFF),
      Color(0xD1FFFFFF),
      BookingDetailPalette.white,
    ],
  );

  /// Hairline that fades out towards both ends.
  static const rule = LinearGradient(
    colors: [Color(0x00000000), Color(0xFFB5B5B5), Color(0x00000000)],
  );

  /// Page header wash behind the status headline.
  static const headerWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.4038],
    colors: [Color(0x66FFFFFF), BookingDetailPalette.white],
  );

  /// White veil that fades the tail of the collapsed About paragraph.
  static const aboutFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00FFFFFF), BookingDetailPalette.white],
  );
}

abstract final class BookingDetailStyle {
  /// Colour is replaced by the brand gradient shader.
  static const status = TextStyle(
    color: BookingDetailPalette.white,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const subtitle = TextStyle(
    color: BookingDetailPalette.subtitle,
    fontSize: 16,
    height: 1.19,
  );

  static const reminder = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 14,
    height: 1.14,
  );

  static const bookingId = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 16,
    height: 1.19,
  );

  static const cardTitle = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  /// Listing name — Figma uses Roboto Black.
  static const listingName = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    height: 1.15,
  );

  static const address = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 18,
    height: 1.44,
  );

  static const link = TextStyle(
    color: BookingDetailPalette.blue,
    fontSize: 18,
    height: 1.17,
  );

  static const sectionLabel = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const date = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const slot = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
  );

  static const stayMeta = TextStyle(
    color: BookingDetailPalette.muted,
    fontSize: 20,
    height: 1.15,
  );

  static const bullet = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 20,
    height: 1.15,
  );

  static const callLabel = TextStyle(
    color: BookingDetailPalette.black,
    fontSize: 18,
    height: 1.17,
  );

  static const chargeLabel = TextStyle(
    color: BookingDetailPalette.meta,
    fontSize: 18,
    height: 0.94,
    letterSpacing: -0.18,
  );

  static const chargeValue = TextStyle(
    color: BookingDetailPalette.meta,
    fontSize: 18,
    height: 1.2,
  );

  static const aboutBody = TextStyle(
    color: BookingDetailPalette.body,
    fontSize: 20,
    height: 1.5,
  );

  static const viewMore = TextStyle(
    color: BookingDetailPalette.body,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  static const billLabel = TextStyle(
    color: BookingDetailPalette.meta,
    fontSize: 16,
    height: 1.06,
    letterSpacing: -0.16,
  );

  static const billValue = TextStyle(
    color: BookingDetailPalette.meta,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const billTotal = TextStyle(
    color: BookingDetailPalette.meta,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
