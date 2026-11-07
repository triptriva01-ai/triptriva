import 'package:flutter/material.dart';

import '../constants/sign_in_constants.dart';

/// "Welcome to" above the triptriva wordmark.
class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          SignInStrings.welcome,
          textAlign: TextAlign.center,
          style: SignInStyle.welcome,
        ),
        SizedBox(height: SignInSizes.welcomeToWordmark),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: SignInStrings.logoLight,
                style: SignInStyle.wordmarkLight,
              ),
              TextSpan(
                text: SignInStrings.logoBold,
                style: SignInStyle.wordmarkBold,
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }
}
