import 'package:flutter/material.dart';

/// Styling shared by every partner-side screen.
abstract final class PartnerPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);

  /// The header/tab green in the Figma export (one off from [green]).
  static const headerGreen = Color(0xFF1F7A62);

  static const white = Colors.white;
  static const black = Colors.black;
  static const avatarIcon = Color(0xFF0B0B0B);
  static const inactiveTab = Color(0xFF42474F);
  static const emptyMessage = Color(0xFF8F8F8F);
  static const navInactive = Color(0xFF7B7B7B);

  /// Card and field outlines, lightest to darkest.
  static const hairline = Color(0xFFD9D9D9);
  static const border = Color(0xFFBABABA);
  static const borderStrong = Color(0xFFC0C0C0);

  /// Body copy, headings and muted labels.
  static const heading = Color(0xFF191C1E);
  static const headingDark = Color(0xFF0B0C0C);
  static const bodyDark = Color(0xFF2D2C2C);
  static const body = Color(0xFF444444);
  static const muted = Color(0xFF767676);
  static const mutedField = Color(0xFF646464);
  static const mutedStrong = Color(0xFF7B7B7B);
  static const mutedLabel = Color(0xFF737784);
  static const subtleText = Color(0xFF324257);
  static const disabled = Color(0xFFDAD9D9);

  /// Status accents.
  static const positive = Color(0xFF007432);
  static const danger = Color(0xFFFF0900);
  static const link = blue;
}

abstract final class PartnerGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [PartnerPalette.green, PartnerPalette.blue],
  );

  /// Soft header wash: white 20% fading into headerGreen 20%.
  static LinearGradient header() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        PartnerPalette.white.withValues(alpha: 0.2),
        PartnerPalette.headerGreen.withValues(alpha: 0.2),
      ],
    );
  }
}

abstract final class PartnerShadows {
  static final bottomNav = [
    BoxShadow(
      color: PartnerPalette.black.withValues(alpha: 0.25),
      blurRadius: 2,
      offset: const Offset(0, -2),
    ),
  ];
}

abstract final class PartnerSizes {
  static const pagePadding = 20.0;

  /// Header content height below the status bar (gradient bleeds behind it).
  static const headerContentHeight = 100.0;
  static const headerRadius = 40.0;
  static const headerTopSpacing = 10.0;
  static const avatarSize = 30.0;
  static const avatarToName = 8.0;
  static const bellSize = 22.0;

  static const tabBarWidth = 350.0;
  static const tabBarHeight = 40.0;
  static const tabRadius = 20.0;

  static const illustrationSize = 140.0;
  static const illustrationToTitle = 12.0;
  static const titleToMessage = 10.0;
  static const messageToAction = 34.0;
  static const emptyStateBottomBias = 50.0;

  static const navHeight = 72.0;
  static const navHorizontalPadding = 30.0;
  static const navIconSize = 22.0;
  static const navIconToLabel = 8.0;
  static const navPillWidth = 50.0;
  static const navPillHeight = 32.0;
  static const navPillRadius = 30.0;
}

abstract final class PartnerStyle {
  static const partnerName = TextStyle(
    color: PartnerPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.19,
    letterSpacing: 0,
  );

  static const tabInactive = TextStyle(
    color: PartnerPalette.inactiveTab,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0,
  );

  static const tabActive = TextStyle(
    color: PartnerPalette.headerGreen,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0,
  );

  /// Figma uses the display face "Righteous"; that font is not bundled, so the
  /// weight is raised to approximate its heavier look.
  static const emptyTitle = TextStyle(
    color: PartnerPalette.white,
    fontSize: 27,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.6,
  );

  static const emptyMessage = TextStyle(
    color: PartnerPalette.emptyMessage,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.14,
    letterSpacing: 0.6,
  );

  static const actionButton = TextStyle(
    color: PartnerPalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.56,
    letterSpacing: 0,
  );

  static const navLabel = TextStyle(
    color: PartnerPalette.navInactive,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.17,
    letterSpacing: 0,
  );

  /// Colour is replaced by the gradient shader on the active item.
  static const navLabelActive = TextStyle(
    color: PartnerPalette.white,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.17,
    letterSpacing: 0,
  );

  /// Screen title beside a back arrow.
  static const pageTitle = TextStyle(
    color: PartnerPalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.15,
  );

  /// Large centred wizard heading.
  static const wizardTitle = TextStyle(
    color: PartnerPalette.headingDark,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.12,
    letterSpacing: -0.64,
  );

  static const wizardSubtitle = TextStyle(
    color: PartnerPalette.black,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const cardTitle = TextStyle(
    color: PartnerPalette.heading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.56,
  );

  static const sectionTitle = TextStyle(
    color: PartnerPalette.heading,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Bold meta line under a card title: date, time slot, status.
  static const cardMeta = TextStyle(
    color: PartnerPalette.inactiveTab,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0.6,
  );

  static const cardMetaAccent = TextStyle(
    color: PartnerPalette.headerGreen,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0.6,
  );

  /// "Booked" / "Completed" badge above a booking card.
  static const statusBooked = TextStyle(
    color: PartnerPalette.headerGreen,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 0.8,
    letterSpacing: 0.6,
  );

  static const statusCompleted = TextStyle(
    color: PartnerPalette.bodyDark,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 0.8,
    letterSpacing: 0.6,
  );

  static const customerName = TextStyle(
    color: PartnerPalette.inactiveTab,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  /// Underlined green call to action inside a card.
  static const cardAction = TextStyle(
    color: PartnerPalette.headerGreen,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0.6,
    decoration: TextDecoration.underline,
    decorationColor: PartnerPalette.headerGreen,
  );

  static const fieldLabel = TextStyle(
    color: PartnerPalette.mutedField,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const fieldValue = TextStyle(
    color: PartnerPalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );

  static const formHeading = TextStyle(
    color: PartnerPalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const rowLabel = TextStyle(
    color: PartnerPalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.15,
  );

  static const rowCaption = TextStyle(
    color: PartnerPalette.body,
    fontSize: 16,
    fontWeight: FontWeight.w300,
    height: 1.19,
  );

  /// Small uppercase caption above a metric.
  static const metricLabel = TextStyle(
    color: PartnerPalette.mutedLabel,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.6,
  );

  static const metricValue = TextStyle(
    color: PartnerPalette.heading,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const footerLink = TextStyle(
    color: PartnerPalette.link,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
  );
}

abstract final class PartnerDecoration {
  /// Standard white card: hairline outline, generous corner radius.
  static BoxDecoration card({
    double radius = 30,
    Color border = PartnerPalette.hairline,
  }) {
    return BoxDecoration(
      color: PartnerPalette.white,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Booking card: the Figma export fades white in from the top edge.
  static BoxDecoration bookingCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.18],
        colors: [
          PartnerPalette.white.withValues(alpha: 0.6),
          PartnerPalette.white,
        ],
      ),
      border: Border.all(color: PartnerPalette.hairline),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: PartnerPalette.black.withValues(alpha: 0.02),
          blurRadius: 2,
        ),
      ],
    );
  }

  /// Rounded outlined input shell used across the wizard.
  static BoxDecoration field({double radius = 30}) {
    return BoxDecoration(
      color: PartnerPalette.white,
      border: Border.all(color: PartnerPalette.border),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Sheet that slides up from the bottom over a dimmed page.
  static const sheet = BoxDecoration(
    color: PartnerPalette.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
  );
}
