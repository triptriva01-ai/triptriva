import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/edit_profile_constants.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/change_picture_card.dart';
import '../widgets/edit_profile_field.dart';

/// Profile page FR-03 — Edit Profile.
class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: EditProfilePalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: EditProfilePalette.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: EditProfileSizes.headerTopSpacing),
              _Header(controller: controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: _Form(controller: controller),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: EditProfileSizes.pagePadding,
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.goBack,
            child: const Icon(
              Icons.arrow_back,
              size: EditProfileSizes.backIconSize,
              color: EditProfilePalette.black,
            ),
          ),
          const SizedBox(width: EditProfileSizes.backIconToTitle),
          const Expanded(
            child: Text(
              EditProfileStrings.title,
              style: EditProfileStyle.pageTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: EditProfileSizes.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: EditProfileSizes.headerToCard),
          ChangePictureCard(controller: controller),
          const SizedBox(height: EditProfileSizes.cardToFields),
          EditProfileField(
            label: EditProfileStrings.username,
            controller: controller.nameController,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: EditProfileSizes.fieldGap),
          EditProfileField(
            label: EditProfileStrings.email,
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: EditProfileSizes.fieldGap),
          EditProfileField(
            label: EditProfileStrings.phone,
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: EditProfileSizes.fieldGap),
          EditProfileField(
            label: EditProfileStrings.password,
            controller: controller.passwordController,
            obscureText: true,
            hintText: EditProfileStrings.passwordHint,
          ),
          const SizedBox(height: EditProfileSizes.fieldsToButton),
          Center(child: _UpdateButton(controller: controller)),
          const SizedBox(height: EditProfileSizes.bottomPadding),
        ],
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final saving = controller.isSaving.value;

      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: EditProfileGradients.prime,
          borderRadius: BorderRadius.circular(EditProfileSizes.buttonRadius),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: saving ? null : controller.save,
            borderRadius: BorderRadius.circular(EditProfileSizes.buttonRadius),
            child: SizedBox(
              width: EditProfileSizes.buttonWidth,
              height: EditProfileSizes.buttonHeight,
              child: Center(
                child: saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: EditProfilePalette.white,
                        ),
                      )
                    : const Text(
                        EditProfileStrings.update,
                        style: EditProfileStyle.button,
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
