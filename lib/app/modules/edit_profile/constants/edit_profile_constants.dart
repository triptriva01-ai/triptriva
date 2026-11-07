import 'package:flutter/material.dart';

abstract final class EditProfileStrings {
  static const title = 'Edit Profile';
  static const changePicture = 'Change Picture';
  static const username = 'Username';
  static const email = 'Email I’d';
  static const phone = 'Phone Number';
  static const password = 'Password';
  static const update = 'Update';

  static const passwordHint = 'Leave blank to keep current';

  static const savedTitle = 'Profile updated';
  static const savedMessage = 'Your changes have been saved.';
  static const photoSavedMessage = 'Your profile photo has been updated.';
  static const failedTitle = 'Could not save';
  static const signInRequired = 'Please sign in again to edit your profile.';
  static const nothingToSave = 'Nothing has changed.';
}

abstract final class EditProfileDurations {
  static const snackbar = Duration(seconds: 3);
}

abstract final class EditProfileSizes {
  static const pagePadding = 20.0;

  static const headerTopSpacing = 10.0;
  static const backIconSize = 22.0;
  static const backIconToTitle = 16.0;
  static const headerToCard = 24.0;

  static const cardRadius = 30.0;
  static const cardVerticalPadding = 20.0;
  static const avatarSize = 150.0;
  static const avatarBorder = 6.0;
  static const avatarToCaption = 20.0;
  static const captionToIcon = 12.0;
  static const editIconSize = 14.0;

  static const cardToFields = 16.0;
  static const fieldGap = 22.0;
  static const labelToField = 8.0;
  static const fieldHeight = 50.0;
  static const fieldRadius = 68.0;
  static const fieldHorizontalPadding = 22.0;

  static const fieldsToButton = 40.0;
  static const buttonWidth = 218.0;
  static const buttonHeight = 49.0;
  static const buttonRadius = 40.0;
  static const bottomPadding = 40.0;
}

abstract final class EditProfilePalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;
  static const fieldBorder = Color(0xFFBABABA);
  static const avatarPlaceholder = Color(0xFFD9D9D9);

  /// Figma uses rgba(196, 196, 196, 0.01) — effectively transparent, but kept
  /// so the field is hit-testable across its whole area.
  static final fieldFill = const Color(0xFFC4C4C4).withValues(alpha: 0.01);
}

abstract final class EditProfileGradients {
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [EditProfilePalette.green, EditProfilePalette.blue],
  );

  /// Brand wash behind the avatar card (Figma: 67.83deg).
  static const cardBrand = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [EditProfilePalette.green, EditProfilePalette.blue],
    stops: [0.2895, 1],
  );

  /// White veil so only the top of the card stays tinted.
  static LinearGradient cardWhiteFade() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        EditProfilePalette.white.withValues(alpha: 0.7),
        EditProfilePalette.white,
        EditProfilePalette.white,
      ],
      stops: const [0, 0.2163, 1],
    );
  }
}

abstract final class EditProfileShadows {
  static final card = [
    BoxShadow(
      color: EditProfilePalette.black.withValues(alpha: 0.1),
      blurRadius: 24,
    ),
  ];
}

abstract final class EditProfileStyle {
  static const pageTitle = TextStyle(
    color: EditProfilePalette.black,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: 0,
  );

  static const caption = TextStyle(
    color: EditProfilePalette.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
    letterSpacing: 0,
  );

  static const label = TextStyle(
    color: EditProfilePalette.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.17,
    letterSpacing: 0,
  );

  static const input = TextStyle(
    color: EditProfilePalette.black,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.17,
    letterSpacing: 0,
  );

  static final hint = input.copyWith(
    color: EditProfilePalette.fieldBorder,
  );

  static const button = TextStyle(
    color: EditProfilePalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.17,
    letterSpacing: 0,
  );
}
