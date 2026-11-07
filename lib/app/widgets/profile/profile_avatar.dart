import 'package:flutter/material.dart';

import 'profile_theme.dart';

/// Circular avatar with a white ring. Falls back to a default icon when the
/// user has no profile image.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ProfileSizes.avatarSize,
      height: ProfileSizes.avatarSize,
      decoration: BoxDecoration(
        color: ProfilePalette.avatarPlaceholder,
        shape: BoxShape.circle,
        border: Border.all(
          color: ProfilePalette.white,
          width: ProfileSizes.avatarBorder,
        ),
        boxShadow: ProfileShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const _DefaultAvatar()
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _DefaultAvatar(),
            ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person,
      size: ProfileSizes.avatarSize * 0.6,
      color: ProfilePalette.white,
    );
  }
}
