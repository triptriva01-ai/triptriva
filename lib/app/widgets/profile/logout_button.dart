import 'package:flutter/material.dart';

import 'profile_theme.dart';

/// Brand gradient logout pill.
class LogoutButton extends StatelessWidget {
  const LogoutButton({
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
        gradient: ProfileGradients.prime,
        borderRadius: BorderRadius.circular(ProfileSizes.logoutRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ProfileSizes.logoutRadius),
          child: SizedBox(
            width: ProfileSizes.logoutWidth,
            height: ProfileSizes.logoutHeight,
            child: Center(child: Text(label, style: ProfileStyle.logout)),
          ),
        ),
      ),
    );
  }
}
