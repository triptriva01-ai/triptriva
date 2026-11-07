import 'package:flutter/material.dart';

import '../../../widgets/profile/profile_theme.dart';
import '../constants/profile_constants.dart';
import '../controllers/profile_controller.dart';

/// Page title with the notification bell.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.controller, super.key});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProfileSizes.pagePadding,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              ProfileStrings.title,
              style: ProfileStyle.pageTitle,
            ),
          ),
          SizedBox.square(
            dimension: ProfileHeaderSizes.bellSize,
            child: Material(
              color: ProfilePalette.white,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: controller.openNotifications,
                child: const Icon(
                  Icons.notifications,
                  size: ProfileHeaderSizes.bellIconSize,
                  color: ProfilePalette.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
