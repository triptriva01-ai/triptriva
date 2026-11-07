import 'package:flutter/material.dart';

abstract final class AdminStrings {
  static const revenue = 'Revenue';
  static const activities = 'Activities';
  static const payment = 'Payment';
  static const users = 'Users';
  static const admin = 'Admin';

  static const paymentRelease = 'Payment Release';
  static const editProfile = 'Edit Profile';
  static const financialHub = 'Financial Hub';

  static const thisMonthTotal = 'THIS MONTH TOTAL';
  static const yearTotal = 'YEAR TOTAL';
  static const incomeGrowth = 'Income Growth';
  static const incomeCategories = 'Income Categories';
  static const usersCategories = 'Users Categories';
  static const bookings = 'Bookings';
  static const total = 'Total';

  static const acceptedActivity = 'Accepted activity';
  static const pendingActivity = 'Pending activity';
  static const reject = 'Reject';
  static const accept = 'Accept';
  static const viewDetails = 'View details';

  static const sortByUser = 'Sort by user';
  static const sortByDate = 'Sort by date';
  static const advancePending = 'Advance pending:';
  static const advancePaid = 'Advance paid:';
  static const paymentCompleted = 'Payment completed:';
  static const fullAmountPaid = 'Full amount paid:';
  static const pending = 'pending:';
  static const secondPayment = '2nd payment:';
  static const fullAmount = 'Full Amount';
  static const viewLess = 'View less';
  static const bookingIdPrefix = 'Booking ID : ';

  static const filterAll = 'All';
  static const filterHouseBoat = 'House boat';
  static const filterStay = 'Stay';
  static const filterAdventure = 'Advneture';
  static const filterPartner = 'Partner';
  static const filterNormal = 'Normal';

  static const accountsSection = 'Accounts & Personal';
  static const paymentMethod = 'Payment Method';
  static const language = 'Language';
  static const feedbacks = 'Feedbacks';
  static const logOut = 'Log Out';
  static const update = 'Update';
  static const changePicture = 'Change Picture';

  static const fieldUsername = 'Username';
  static const fieldEmail = 'Email I’d';
  static const fieldPhone = 'Phone Number';
  static const fieldPassword = 'Password';

  static const empty = 'Nothing to show yet.';
  static const accessDenied = 'This area is for administrators only.';

  static String bookingsCount(int count) => '$count Bookings';

  static const pendingTitle = 'Coming soon';
  static String pendingMessage(String feature) =>
      '$feature will open once the screen is built.';
}

abstract final class AdminDurations {
  static const snackbar = Duration(seconds: 2);
}

abstract final class AdminSizes {
  static const pagePadding = 20.0;

  static const headerTop = 60.0;
  static const headerBottom = 20.0;
  static const headerWashHeight = 280.0;
  static const headerRadius = 40.0;

  static const cardRadius = 24.0;
  static const cardPadding = 20.0;
  static const sectionGap = 24.0;
  static const listGap = 16.0;

  /// Minimums, not fixed sizes: everything grows with the system font.
  static const statCardMinHeight = 140.0;
  static const chipHeight = 33.0;
  static const chipRadius = 20.0;
  static const chipGap = 10.0;

  static const avatarSize = 48.0;
  static const smallAvatarSize = 30.0;
  static const tinyAvatarSize = 12.0;

  static const chartHeight = 218.0;
  static const donutSize = 128.0;
  static const donutGap = 32.0;

  static const navHeight = 72.0;
  static const navRadius = 40.0;
  static const navPillWidth = 46.0;
  static const navPillHeight = 34.0;

  static const progressDotSize = 14.0;
  static const progressTrackHeight = 2.0;

  static const sheetRadius = 30.0;
  static const fieldRadius = 68.0;
  static const fieldMinHeight = 50.0;

  static const listBottomPadding = 40.0;
}

abstract final class AdminPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const deepBlue = Color(0xFF004A6D);
  static const tealDark = Color(0xFF004D3C);
  static const blueDark = Color(0xFF005A84);

  static const white = Colors.white;
  static const black = Colors.black;

  static const page = Color(0xFFF9F9FC);
  static const washTop = Color(0xFFE0F2F1);

  static const heading = Color(0xFF1A1C1E);
  static const body = Color(0xFF3E4944);
  static const muted = Color(0xFF6F7A74);
  static const meta = Color(0xFF42474F);
  static const chipInactive = Color(0xFF42474F);
  static const border = Color(0x4DBEC9C3);
  static const softBorder = Color(0x33BEC9C3);
  static const hairline = Color(0xFFD9D9D9);
  static const navInactive = Color(0xFF7B7B7B);
  static const fieldBorder = Color(0xFFBABABA);

  /// Payment stages.
  static const stagePending = Color(0xFFFF0000);
  static const stageAdvance = Color(0xFFFFC800);
  static const stageComplete = Color(0xFF00B919);
  static const stageIdle = Color(0xFFD5D5D5);

  static const trend = Color(0xFF1F7A62);
}

abstract final class AdminGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AdminPalette.green, AdminPalette.blue],
  );

  /// Mint wash behind the revenue header.
  static const headerWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AdminPalette.washTop, AdminPalette.page],
  );

  /// Card background on the payment sheets: brand tint washed out by white.
  static const cardWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.0001, 0.1827],
    colors: [Color(0x99FFFFFF), Color(0xD1FFFFFF), AdminPalette.white],
  );

  /// Hairline that fades out towards both ends.
  static const rule = LinearGradient(
    colors: [Color(0x00000000), Color(0xFFB5B5B5), Color(0x00000000)],
  );

  /// Profile card: brand gradient almost entirely veiled by white.
  static const profileCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.2163],
    colors: [Color(0xB3FFFFFF), AdminPalette.white],
  );
}

abstract final class AdminStyle {
  /// Colour is replaced by the brand gradient shader.
  static const pageTitle = TextStyle(
    color: AdminPalette.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const sectionTitle = TextStyle(
    color: AdminPalette.heading,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.56,
  );

  static const statLabel = TextStyle(
    color: AdminPalette.muted,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const statValue = TextStyle(
    color: AdminPalette.heading,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const statCaption = TextStyle(
    color: AdminPalette.muted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const statTrend = TextStyle(
    color: AdminPalette.trend,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.33,
  );

  static const chip = TextStyle(
    color: AdminPalette.chipInactive,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  /// Colour is replaced by the brand gradient shader.
  static const chipActive = TextStyle(
    color: AdminPalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const tab = TextStyle(
    color: Color(0xFF2D2C2C),
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.56,
  );

  static const tabActive = TextStyle(
    color: AdminPalette.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const cardTitle = TextStyle(
    color: AdminPalette.heading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  static const cardCategory = TextStyle(
    color: AdminPalette.green,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.6,
  );

  static const cardOwner = TextStyle(
    color: AdminPalette.black,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.6,
  );

  static const cardMeta = TextStyle(
    color: AdminPalette.muted,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const cardAmount = TextStyle(
    color: AdminPalette.green,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.56,
  );

  static const personName = TextStyle(
    color: AdminPalette.meta,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const stageAmount = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.56,
  );

  static const stageLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 0.6,
  );

  static const stageChip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.45,
    letterSpacing: 0.6,
  );

  static const slotMeta = TextStyle(
    color: AdminPalette.meta,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.23,
    letterSpacing: 0.6,
  );

  static const billLabel = TextStyle(
    color: Color(0xFF727783),
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.06,
    letterSpacing: -0.16,
  );

  static const billTotal = TextStyle(
    color: Color(0xFF2D2C2C),
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.06,
    letterSpacing: -0.16,
  );

  static const rejectAction = TextStyle(
    color: AdminPalette.stagePending,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const linkAction = TextStyle(
    color: AdminPalette.blue,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
    decoration: TextDecoration.underline,
    decorationColor: AdminPalette.blue,
  );

  static const navLabel = TextStyle(
    color: AdminPalette.navInactive,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.17,
  );

  /// Colour is replaced by the brand gradient shader.
  static const navLabelActive = TextStyle(
    color: AdminPalette.white,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const profileName = TextStyle(
    color: AdminPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  static const profilePhone = TextStyle(
    color: AdminPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const settingsSection = TextStyle(
    color: Color(0xFF727783),
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
  );

  static const settingsRow = TextStyle(
    color: AdminPalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.15,
  );

  static const fieldLabel = TextStyle(
    color: AdminPalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const fieldValue = TextStyle(
    color: AdminPalette.black,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.17,
  );

  static const cta = TextStyle(
    color: AdminPalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.17,
  );
}
