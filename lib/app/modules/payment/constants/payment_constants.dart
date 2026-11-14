import 'package:flutter/material.dart';

abstract final class PaymentStrings {
  static const totalAmount = 'Total amount :';
  static const paymentMethods = 'Payment methods';
  static const upi = 'UPI';
  static const upiSubtitle = 'Pay by any UPI app';
  static const upiOffer = '50% OFF on UPI pay';
  static const card = 'Debit/Credit/ATM Card';
  static const cardSubtitle = 'Add card details';
  static const otherUpi = 'Pay with other UPI app';
  static const otherUpiSubtitle = 'Choose your app';

  static const nameOnCard = 'Name on card';
  static const nameHint = 'Name';
  static const cardNumber = 'Card number';
  static const cardNumberHint = 'XXXX  XXXX  XXXX  XXXX';
  static const expiry = 'Card expire date';
  static const expiryHint = 'MM / YY';
  static const cvv = 'CVV';
  static const cvvHint = '•••';

  static const billSummary = 'Bill Summary';
  static const totalTripFee = 'Total trip fee';
  static const platformFee = 'Platform fee';
  static const gst = 'GST';
  static const couponDiscount = 'Coupon Discount';
  static const youHaveSaved = 'You have saved';
  static const toPay = 'To pay';

  static String pay(String amount) => 'Pay $amount';
  static const paymentFailed = 'Payment failed';
  static const paymentCancelled = 'Payment cancelled.';
  static const paymentDeclined = 'The payment did not go through. Please try again.';
  static const merchantName = 'TripTriva';
  static const upiHint = 'Google Pay, PhonePe, Paytm or any UPI app';
  static const cardHint = 'Visa, Mastercard, RuPay — entered securely on the next screen';
  static const orderFailed = 'Could not start the payment. Please try again.';
  static const gatewayMissing =
      'Online payment is not set up yet. Please try again later.';

  static const upiApps = ['Google Pay', 'PhonePe', 'Paytm'];

  // Success screen.
  static const success = 'SUCCESS';
  static const bookingCompleted = 'Your booking has been\ncompleted';
  static String bookingId(String id) => 'Booking ID : $id';
  static const copied = 'Booking ID copied';
  static const goToExplore = 'Go to Explore';
  static const goToReserve = 'Go to Reserve';

  static const logoLight = 'trip';
  static const logoBold = 'triva';
}

abstract final class PaymentSizes {
  static const pagePadding = 20.0;
  static const headerHeight = 210.0;
  static const sheetOverlap = 40.0;
  static const sheetRadius = 40.0;

  static const cardRadius = 20.0;
  static const cardPadding = 16.0;
  static const cardGap = 12.0;
  static const sectionGap = 24.0;
  static const titleToBody = 12.0;
  static const methodIconSize = 22.0;
  static const appIconSize = 24.0;
  static const fieldGap = 14.0;
  static const billRowGap = 12.0;

  static const buttonHeight = 52.0;
  static const buttonRadius = 30.0;

  // Success screen.
  static const heroHeight = 330.0;
  static const badgeSize = 140.0;
  static const badgeRing = 12.0;
  static const checkSize = 72.0;
}

abstract final class PaymentPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;
  static const border = Color(0xFFDFDFDF);
  static const expanded = Color(0xFFE6E6E6);
  static const muted = Color(0xFF8F8F8F);
  static const meta = Color(0xFF727783);
  static const struck = Color(0xFF999999);
  static const saving = Color(0xFF0CA201);
  static const divider = Color(0xFFDFDFDF);
  static const success = Color(0xFF1F8AA5);
}

abstract final class PaymentGradients {
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [PaymentPalette.green, PaymentPalette.blue],
  );

  static const header = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [PaymentPalette.green, PaymentPalette.blue],
  );
}

abstract final class PaymentShadows {
  static final card = [
    BoxShadow(color: PaymentPalette.black.withValues(alpha: 0.08), blurRadius: 10),
  ];
}

abstract final class PaymentStyle {
  static const totalLabel = TextStyle(
    color: PaymentPalette.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const totalValue = TextStyle(
    color: PaymentPalette.white,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.17,
  );

  static const section = TextStyle(
    color: PaymentPalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const methodTitle = TextStyle(
    color: PaymentPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
  );

  static const methodSubtitle = TextStyle(
    color: PaymentPalette.muted,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const offer = TextStyle(
    color: PaymentPalette.saving,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const appName = TextStyle(
    color: PaymentPalette.black,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const otherUpi = TextStyle(
    color: PaymentPalette.blue,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const otherUpiSubtitle = TextStyle(
    color: PaymentPalette.blue,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const fieldLabel = TextStyle(
    color: PaymentPalette.black,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const fieldValue = TextStyle(
    color: PaymentPalette.black,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const fieldHint = TextStyle(
    color: PaymentPalette.muted,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const billLabel = TextStyle(
    color: PaymentPalette.black,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const billValue = TextStyle(
    color: PaymentPalette.black,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const billStruck = TextStyle(
    color: PaymentPalette.struck,
    fontSize: 14,
    height: 1.2,
    decoration: TextDecoration.lineThrough,
    decorationColor: PaymentPalette.struck,
  );

  static const billSaving = TextStyle(
    color: PaymentPalette.saving,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const billTotal = TextStyle(
    color: PaymentPalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const button = TextStyle(
    color: PaymentPalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const logo = TextStyle(
    color: Color(0x992D9CDB),
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  // Success screen.
  static const successTitle = TextStyle(
    color: PaymentPalette.success,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.17,
    letterSpacing: 1,
  );

  static const successBody = TextStyle(
    color: PaymentPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const bookingId = TextStyle(
    color: PaymentPalette.muted,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const outlineButton = TextStyle(
    color: PaymentPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.19,
  );
}
