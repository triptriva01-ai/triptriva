import 'package:flutter/material.dart';

import '../constants/edit_profile_constants.dart';

/// A labelled pill input, matching the Figma field style.
class EditProfileField extends StatelessWidget {
  const EditProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: EditProfileStyle.label),
        const SizedBox(height: EditProfileSizes.labelToField),
        Container(
          height: EditProfileSizes.fieldHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: EditProfileSizes.fieldHorizontalPadding,
          ),
          decoration: BoxDecoration(
            color: EditProfilePalette.fieldFill,
            border: Border.all(color: EditProfilePalette.fieldBorder),
            borderRadius: BorderRadius.circular(EditProfileSizes.fieldRadius),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: EditProfileStyle.input,
              cursorColor: EditProfilePalette.green,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                hintStyle: EditProfileStyle.hint,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
