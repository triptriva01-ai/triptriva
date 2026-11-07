import 'package:flutter/material.dart';

import '../constants/sign_in_constants.dart';
import '../controllers/sign_in_controller.dart';
import 'identifier_field.dart';
import 'or_divider.dart';
import 'primary_gradient_button.dart';
import 'social_sign_in_buttons.dart';
import 'welcome_logo.dart';

class SignInBody extends StatelessWidget {
  const SignInBody({required this.controller, super.key});

  final SignInController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SignInSizes.pagePadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: height * SignInSizes.topSpacingFactor),
                    const WelcomeLogo(),
                    SizedBox(height: height * SignInSizes.logoToFormFactor),
                    const Text(
                      SignInStrings.loginTitle,
                      textAlign: TextAlign.center,
                      style: SignInStyle.title,
                    ),
                    const SizedBox(height: SignInSizes.titleToForm),
                    IdentifierField(controller: controller),
                    const SizedBox(height: SignInSizes.fieldToButton),
                    PrimaryGradientButton(
                      label: SignInStrings.continueButton,
                      onTap: controller.submit,
                    ),
                    const SizedBox(height: SignInSizes.buttonToDivider),
                    const OrDivider(),
                    const SizedBox(height: SignInSizes.dividerToSocial),
                    SocialSignInButtons(controller: controller),
                    SizedBox(
                      height: height * SignInSizes.bottomSpacingFactor,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
