import 'package:flutter/material.dart';

import '../../../widgets/profile/profile_theme.dart';
import '../constants/profile_constants.dart';
import '../controllers/profile_controller.dart';

/// Wishlist shortcut and Edit Profile, side by side.
class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({required this.controller, super.key});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.favorite,
            label: ProfileStrings.wishlist,
            onTap: controller.openWishlist,
          ),
        ),
        const SizedBox(width: ProfileHeaderSizes.quickActionGap),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.edit,
            label: ProfileStrings.editProfile,
            onTap: controller.openEditProfile,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ProfilePalette.white,
        borderRadius: BorderRadius.circular(ProfileSizes.cardRadius),
        boxShadow: ProfileShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ProfileSizes.cardRadius),
          child: SizedBox(
            height: ProfileHeaderSizes.quickActionHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: ProfileSizes.rowIconSize,
                  color: ProfilePalette.black,
                ),
                const SizedBox(width: ProfileSizes.rowIconToLabel),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ProfileStyle.row,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
