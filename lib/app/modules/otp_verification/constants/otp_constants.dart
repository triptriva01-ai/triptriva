import 'package:flutter/material.dart';

abstract final class OtpStrings {
  static const title = 'Verify it\'s you';
  static const subtitlePrefix = 'Enter the code we sent to';
  static const verifyButton = 'Verify';
  static const resendPrompt = "Didn't get it? ";
  static const resendAction = 'Resend';
  static String resendIn(int seconds) => 'Resend in ${seconds}s';

  static const emptyCode = 'Enter the code';
  static const shortCode = 'Enter all 6 digits.';
  static const failedTitle = 'Verification failed';
  static const sentTitle = 'Code sent';
  static const sentMessage = 'A new code is on its way.';

  /// Only shown while the server exposes the code for local testing.
  static String devCode(String code) => 'Dev code: $code';
}

abstract final class OtpDurations {
  static const snackbar = Duration(seconds: 3);
  static const tick = Duration(seconds: 1);
}

abstract final class OtpSizes {
  static const pagePadding = 20.0;
  static const codeLength = 6;

  static const topSpacingFactor = 0.1;
  static const titleToSubtitle = 12.0;
  static const subtitleToBoxes = 40.0;
  static const boxesToButton = 36.0;
  static const buttonToResend = 24.0;

  static const boxWidth = 48.0;
  static const boxHeight = 60.0;
  static const boxRadius = 16.0;
  static const boxGap = 10.0;

  static const buttonHeight = 50.0;
  static const buttonRadius = 50.0;
  static const backIconSize = 22.0;
  static const headerToBody = 24.0;
}

abstract final class OtpPalette {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;
  static const boxBorder = Color(0xFFD5D5D5);
  static const subtitle = Color(0xFF727783);
  static const disabled = Color(0xFF9E9E9E);
}

abstract final class OtpGradients {
  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [OtpPalette.green, OtpPalette.blue],
  );
}

abstract final class OtpStyle {
  static const title = TextStyle(
    color: OtpPalette.black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.17,
    letterSpacing: 0,
  );

  static const subtitle = TextStyle(
    color: OtpPalette.subtitle,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0,
  );

  static const digit = TextStyle(
    color: OtpPalette.black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: 0,
  );

  static const button = TextStyle(
    color: OtpPalette.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.17,
    letterSpacing: 0,
  );

  static const resend = TextStyle(
    color: OtpPalette.subtitle,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.19,
    letterSpacing: 0,
  );

  static const resendAction = TextStyle(
    color: OtpPalette.blue,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.19,
    letterSpacing: 0,
  );

  static const devCode = TextStyle(
    color: OtpPalette.disabled,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0,
  );
}
