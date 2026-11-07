import 'package:flutter/material.dart';

/// Styling shared by the traveller and partner profile screens.
abstract final class ProfilePalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;
  static const sectionLabel = Color(0xFF727783);
  static const divider = Color(0xFFD9D9D9);
  static const chevron = Color(0xFFBABABA);
  static const avatarPlaceholder = Color(0xFFD9D9D9);
}

abstract final class ProfileSizes {
  static const pagePadding = 20.0;
  static const sheetRadius = 40.0;
  static const cardRadius = 30.0;

  static const avatarSize = 150.0;
  static const avatarBorder = 6.0;
  static const infoCardPadding = 20.0;
  static const avatarToName = 20.0;
  static const nameToPhone = 6.0;

  static const bandVerticalPadding = 20.0;
  static const bandHorizontalPadding = 30.0;

  static const rowIconSize = 22.0;
  static const rowIconToLabel = 12.0;
  static const chevronSize = 22.0;
  static const dividerThickness = 1.0;

  static const logoutWidth = 104.0;
  static const logoutHeight = 49.0;
  static const logoutRadius = 40.0;

  static const sheetTopPadding = 26.0;
  static const sectionLabelToRows = 24.0;
  static const rowToDivider = 20.0;
  static const groupGap = 52.0;
  static const rowsToLogout = 40.0;
  static const logoutToBottom = 30.0;
}

abstract final class ProfileGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [ProfilePalette.green, ProfilePalette.blue],
  );

  /// Brand wash behind the profile card (Figma: 67.83deg).
  static const cardBrand = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [ProfilePalette.green, ProfilePalette.blue],
    stops: [0.2895, 1],
  );

  /// White veil over [cardBrand] so only the top of the card stays tinted.
  static LinearGradient cardWhiteFade() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ProfilePalette.white.withValues(alpha: 0.7),
        ProfilePalette.white,
        ProfilePalette.white,
      ],
      stops: const [0, 0.2163, 1],
    );
  }

  /// The full-bleed band: prime gradient under a 70% white overlay.
  static final band = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.lerp(ProfilePalette.green, ProfilePalette.white, 0.7)!,
      Color.lerp(ProfilePalette.blue, ProfilePalette.white, 0.7)!,
    ],
  );
}

abstract final class ProfileShadows {
  /// Soft ambient shadow on the profile card and quick action buttons.
  static final card = [
    BoxShadow(
      color: ProfilePalette.black.withValues(alpha: 0.1),
      blurRadius: 24,
    ),
  ];

  /// White sheet that sits above the band.
  static final sheetAbove = [
    BoxShadow(
      color: ProfilePalette.black.withValues(alpha: 0.18),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// White sheet that sits below the band.
  static final sheetBelow = [
    BoxShadow(
      color: ProfilePalette.black.withValues(alpha: 0.18),
      blurRadius: 6,
      offset: const Offset(0, -2),
    ),
  ];
}

abstract final class ProfileStyle {
  static const pageTitle = TextStyle(
    color: ProfilePalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: 0,
  );

  static const name = TextStyle(
    color: ProfilePalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0,
  );

  static const phone = TextStyle(
    color: ProfilePalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const bandLight = TextStyle(
    color: ProfilePalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: 0,
  );

  static const bandBold = TextStyle(
    color: ProfilePalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0,
  );

  static const sectionLabel = TextStyle(
    color: ProfilePalette.sectionLabel,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
    letterSpacing: 0,
  );

  static const row = TextStyle(
    color: ProfilePalette.black,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: 0,
  );

  static const logout = TextStyle(
    color: ProfilePalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.17,
    letterSpacing: 0,
  );
}
