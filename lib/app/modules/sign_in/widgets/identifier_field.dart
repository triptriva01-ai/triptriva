import 'package:flutter/material.dart';

import '../constants/sign_in_constants.dart';
import '../controllers/sign_in_controller.dart';

/// Single field accepting either a phone number or an email address.
class IdentifierField extends StatelessWidget {
  const IdentifierField({required this.controller, super.key});

  final SignInController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SignInSizes.fieldHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: SignInSizes.fieldHorizontalPadding,
      ),
      decoration: BoxDecoration(
        color: SignInPalette.white,
        border: Border.all(color: SignInPalette.fieldBorder),
        borderRadius: BorderRadius.circular(SignInSizes.fieldRadius),
      ),
      child: Center(
        child: TextField(
          controller: controller.identifierController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.submit(),
          style: SignInStyle.input,
          cursorColor: SignInPalette.green,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: SignInStrings.identifierHint,
            hintStyle: SignInStyle.hint,
          ),
        ),
      ),
    );
  }
}
