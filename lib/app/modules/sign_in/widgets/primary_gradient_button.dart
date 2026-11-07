import 'package:flutter/material.dart';

import '../constants/sign_in_constants.dart';

/// Full-width brand gradient pill used for the Continue action.
class PrimaryGradientButton extends StatelessWidget {
  const PrimaryGradientButton({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: SignInGradients.prime,
        borderRadius: BorderRadius.circular(SignInSizes.buttonRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SignInSizes.buttonRadius),
          child: SizedBox(
            height: SignInSizes.buttonHeight,
            width: double.infinity,
            child: Center(
              child: Text(label, style: SignInStyle.primaryButton),
            ),
          ),
        ),
      ),
    );
  }
}
