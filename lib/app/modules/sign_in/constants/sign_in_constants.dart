import 'package:flutter/material.dart';

abstract final class SignInStrings {
  static const welcome = 'Welcome to';
  static const logoLight = 'trip';
  static const logoBold = 'triva';
  static const loginTitle = 'Login or Sign up';
  static const identifierHint = 'Phone number or email';
  static const continueButton = 'Continue';
  static const orLabel = 'or';

  static const invalidIdentifierTitle = 'Enter your details';
  static const invalidIdentifierMessage =
      'Please enter a valid phone number or email address.';

  static const google = 'Google';
  static const apple = 'Apple';

  static const signInFailedTitle = 'Sign-in failed';

  /// Shown when the device cannot open a socket to the API at all. Names the
  /// usual culprit rather than dumping a raw SocketException on the user:
  /// over USB the app reaches the API through `adb reverse`, and that tunnel
  /// is dropped whenever the device reconnects or adb restarts.
  static const backendUnreachable =
      "Can't reach the TripTriva server. Start it, then run: "
      'adb reverse tcp:5080 tcp:5080';
  static const googleNotConfigured =
      'Google sign-in is not set up yet. Add the Web client ID to '
      'GoogleAuthConfig.';
  static const appleUnsupported =
      'Sign in with Apple is available on iPhone and iPad. On Android, use '
      'Google or your phone number.';
  static const googleFailed =
      'Could not sign in with Google. Please try again.';
}

abstract final class SignInDurations {
  static const snackbar = Duration(seconds: 3);
}

abstract final class SignInSizes {
  static const pagePadding = 20.0;

  static const topSpacingFactor = 0.2;
  static const logoToFormFactor = 0.13;
  static const bottomSpacingFactor = 0.06;

  static const welcomeFontSize = 20.0;
  static const welcomeToWordmark = 8.0;
  static const wordmarkFontSize = 44.0;

  static const titleToForm = 26.0;
  static const fieldHeight = 60.0;
  static const fieldRadius = 50.0;
  static const fieldHorizontalPadding = 20.0;
  static const fieldToButton = 16.0;

  static const buttonHeight = 50.0;
  static const buttonRadius = 50.0;
  static const buttonToDivider = 20.0;

  static const dividerThickness = 2.0;
  static const dividerLabelPadding = 16.0;
  static const dividerToSocial = 20.0;

  static const socialSize = 70.0;
  static const socialRadius = 20.0;
  static const socialGap = 22.0;
  static const socialIconSize = 20.0;

  static const titleFontSize = 24.0;
  static const inputFontSize = 20.0;
  static const buttonFontSize = 18.0;
  static const orFontSize = 19.0;
}

abstract final class SignInPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);

  /// Wordmark teal from the Figma logo artwork.
  static const wordmark = Color(0xFF1F777F);

  static const white = Colors.white;
  static const black = Colors.black;
  static const fieldBorder = Color(0xFFD5D5D5);
  static const socialBorder = Color(0xFFD9D9D9);
  static const hint = Color(0xFF3F3F3F);
  static const divider = Color(0xFFD9D9D9);
}

abstract final class SignInGradients {
  /// The "prime g" brand gradient.
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [SignInPalette.green, SignInPalette.blue],
  );
}

abstract final class SignInStyle {
  static const welcome = TextStyle(
    color: SignInPalette.black,
    fontSize: SignInSizes.welcomeFontSize,
    fontWeight: FontWeight.w900,
    height: 1.42,
    letterSpacing: -0.4,
  );

  static const wordmarkLight = TextStyle(
    color: SignInPalette.wordmark,
    fontSize: SignInSizes.wordmarkFontSize,
    fontWeight: FontWeight.w400,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const wordmarkBold = TextStyle(
    color: SignInPalette.wordmark,
    fontSize: SignInSizes.wordmarkFontSize,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const title = TextStyle(
    color: SignInPalette.black,
    fontSize: SignInSizes.titleFontSize,
    fontWeight: FontWeight.w600,
    height: 1.17,
    letterSpacing: 0,
  );

  static const input = TextStyle(
    color: SignInPalette.black,
    fontSize: SignInSizes.inputFontSize,
    fontWeight: FontWeight.w300,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static const hint = TextStyle(
    color: SignInPalette.hint,
    fontSize: SignInSizes.inputFontSize,
    fontWeight: FontWeight.w300,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static const primaryButton = TextStyle(
    color: SignInPalette.white,
    fontSize: SignInSizes.buttonFontSize,
    fontWeight: FontWeight.w700,
    height: 1.17,
    letterSpacing: 0,
  );

  static const orLabel = TextStyle(
    color: SignInPalette.black,
    fontSize: SignInSizes.orFontSize,
    fontWeight: FontWeight.w400,
    height: 1.16,
    letterSpacing: 0,
  );
}
