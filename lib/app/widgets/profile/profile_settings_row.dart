import 'package:flutter/material.dart';

import 'profile_theme.dart';

/// A single "Accounts & Personal" entry: icon, label and trailing chevron.
class ProfileSettingsRow extends StatelessWidget {
  const ProfileSettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              size: ProfileSizes.rowIconSize,
              color: ProfilePalette.black,
            ),
            const SizedBox(width: ProfileSizes.rowIconToLabel),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ProfileStyle.row,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: ProfileSizes.chevronSize,
              color: ProfilePalette.chevron,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsDivider extends StatelessWidget {
  const ProfileSettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: ProfilePalette.divider,
      child: SizedBox(
        width: double.infinity,
        height: ProfileSizes.dividerThickness,
      ),
    );
  }
}
