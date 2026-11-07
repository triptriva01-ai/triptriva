import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/edit_profile_constants.dart';
import '../controllers/edit_profile_controller.dart';

/// Avatar over the brand-gradient card, with the "Change Picture" action.
class ChangePictureCard extends StatelessWidget {
  const ChangePictureCard({required this.controller, super.key});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: EditProfileGradients.cardBrand,
        borderRadius: BorderRadius.circular(EditProfileSizes.cardRadius),
        boxShadow: EditProfileShadows.card,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: EditProfileGradients.cardWhiteFade(),
          borderRadius: BorderRadius.circular(EditProfileSizes.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: EditProfileSizes.cardVerticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatar(controller: controller),
              const SizedBox(height: EditProfileSizes.avatarToCaption),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.changePicture,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      EditProfileStrings.changePicture,
                      style: EditProfileStyle.caption,
                    ),
                    SizedBox(width: EditProfileSizes.captionToIcon),
                    Icon(
                      Icons.edit,
                      size: EditProfileSizes.editIconSize,
                      color: EditProfilePalette.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.changePicture,
      child: Container(
        width: EditProfileSizes.avatarSize,
        height: EditProfileSizes.avatarSize,
        decoration: BoxDecoration(
          color: EditProfilePalette.avatarPlaceholder,
          shape: BoxShape.circle,
          border: Border.all(
            color: EditProfilePalette.white,
            width: EditProfileSizes.avatarBorder,
          ),
          boxShadow: EditProfileShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Obx(() {
          if (controller.isUploadingPhoto.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final url = controller.avatarUrl.value;
          if (url.isEmpty) {
            return const _DefaultAvatar();
          }

          return Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const _DefaultAvatar(),
          );
        }),
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
      size: EditProfileSizes.avatarSize * 0.6,
      color: EditProfilePalette.white,
    );
  }
}
