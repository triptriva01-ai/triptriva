import 'package:flutter/material.dart';

import 'profile_avatar.dart';
import 'profile_theme.dart';

/// Profile information card: photo, name and mobile number over a brand
/// gradient that fades into white.
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    required this.name,
    required this.phone,
    required this.imageUrl,
    super.key,
  });

  final String name;
  final String phone;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: ProfileGradients.cardBrand,
        borderRadius: BorderRadius.circular(ProfileSizes.cardRadius),
        boxShadow: ProfileShadows.card,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: ProfileGradients.cardWhiteFade(),
          borderRadius: BorderRadius.circular(ProfileSizes.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: ProfileSizes.infoCardPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(imageUrl: imageUrl),
              const SizedBox(height: ProfileSizes.avatarToName),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ProfileStyle.name,
              ),
              const SizedBox(height: ProfileSizes.nameToPhone),
              Text(
                phone,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: ProfileStyle.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
