import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/partner/partner_fields.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/partner_onboarding_controller.dart';
import 'onboarding_intro_steps.dart';

/// Step 4a — "About you": the name and email shown to guests.
class AboutYouStep extends StatelessWidget {
  const AboutYouStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(title: 'About you'),
        const _FieldLabel(icon: Icons.person_outline, label: "partner's name"),
        const SizedBox(height: 12),
        PartnerTextField(
          hint: 'Your name',
          controller: controller.partnerNameField,
          onChanged: (_) => controller.step.refresh(),
        ),
        const SizedBox(height: 26),
        const _FieldLabel(
          icon: Icons.mail_outline,
          label: "partner's mail ID",
        ),
        const SizedBox(height: 12),
        PartnerTextField(
          hint: 'you@example.com',
          controller: controller.partnerEmailField,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => controller.step.refresh(),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: PartnerPalette.black),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: PartnerPalette.body,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Step 4b — "Proof": a checklist of the verifications required before a
/// listing can be published. Each row opens its own sub-screen.
class ProofStep extends StatelessWidget {
  const ProofStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Proof',
          subtitle: 'Add more details to verify your activity is real',
        ),
        Obx(
          () => Column(
            children: [
              _ProofRow(
                title: 'Add your number',
                description:
                    'We will sent you an otp to confirm your number.',
                isDone: controller.isPhoneVerified.value,
                onTap: () => controller.goTo(OnboardingStep.phoneEntry),
              ),
              const SizedBox(height: 70),
              _ProofRow(
                title: 'Verify your identity',
                description:
                    "Add your government ID to help us make sure you're really "
                    'you and is required to publish your listing',
                isDone: controller.isIdentityVerified.value,
                onTap: () => controller.goTo(OnboardingStep.identityType),
              ),
              const SizedBox(height: 70),
              _ProofRow(
                title: 'Verify your licence',
                description:
                    'Share your licence of your activity to verify its a real '
                    'activity and is required to publish your listing.',
                isDone: controller.isLicenceVerified.value,
                onTap: controller.openLicenceCapture,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProofRow extends StatelessWidget {
  const _ProofRow({
    required this.title,
    required this.description,
    required this.isDone,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isDone)
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    gradient: PartnerGradients.prime,
                    shape: BoxShape.circle,
                  ),
                  foregroundDecoration: BoxDecoration(
                    color: PartnerPalette.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: PartnerPalette.black,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: PartnerPalette.mutedStrong,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: PartnerStyle.rowCaption),
        ],
      ),
    );
  }
}

/// Step 4b-i — "Add your number", with the OTP field underneath once a code
/// has been sent.
class PhoneEntryStep extends StatelessWidget {
  const PhoneEntryStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Add your number',
          subtitle: 'We will sent you an otp to confirm your number.',
          alignment: CrossAxisAlignment.start,
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: PartnerDecoration.field(radius: 68),
          child: Row(
            children: [
              Obx(
                () => Text(
                  controller.dialCode.value,
                  style: const TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: PartnerPalette.mutedStrong,
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 40, color: PartnerPalette.border),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: controller.phoneNumber,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => controller.onPhoneChanged(),
                  style: PartnerStyle.fieldValue.copyWith(fontSize: 20),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '000 000 0000',
                    hintStyle: PartnerStyle.fieldLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final sent = controller.isOtpSent.value;
          final error = controller.otpError.value;
          final devCode = controller.otpDevCode.value;
          final wait = controller.secondsUntilResend.value;
          final busy = controller.isSendingOtp.value ||
              controller.isVerifyingOtp.value;
          // Read so the button re-evaluates as the number is typed.
          controller.step.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sent) ...[
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration:
                      PartnerDecoration.card(border: PartnerPalette.border),
                  child: TextField(
                    controller: controller.phoneCode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      controller.otpError.value = '';
                      controller.step.refresh();
                      // Six digits is the whole code — submit straight away.
                      if (value.length == 6) controller.verifyPhoneOtp();
                    },
                    style: const TextStyle(fontSize: 24, letterSpacing: 12),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText: '••••••',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        devCode == null ? '' : 'Dev code: $devCode',
                        style: PartnerStyle.rowCaption,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.canSendOtp
                          ? controller.sendPhoneOtp
                          : null,
                      child: Text(
                        wait > 0 ? 'Resend in ${wait}s' : 'Resend OTP',
                        style: PartnerStyle.rowCaption.copyWith(
                          color: wait > 0
                              ? PartnerPalette.mutedStrong
                              : PartnerPalette.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (error.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  error,
                  style: const TextStyle(
                    color: PartnerPalette.danger,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: PartnerPrimaryButton(
                  label: busy
                      ? (sent ? 'Verifying…' : 'Sending…')
                      : (sent ? 'Verify' : 'Send OTP'),
                  expand: true,
                  onPressed: busy
                      ? null
                      : sent
                          ? (controller.phoneCode.text.length == 6
                              ? controller.verifyPhoneOtp
                              : null)
                          : (controller.canSendOtp
                              ? controller.sendPhoneOtp
                              : null),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// Step 4b-ii — "Verifying your identity": pick which document to upload.
class IdentityTypeStep extends StatelessWidget {
  const IdentityTypeStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  static const _icons = [
    Icons.badge_outlined,
    Icons.credit_card,
    Icons.account_box_outlined,
    Icons.book_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Verifying your identity',
          alignment: CrossAxisAlignment.start,
        ),
        const Text(
          'Choose one method and we will verify it and won’t share it with '
          'others partners or guest',
          style: TextStyle(color: PartnerPalette.black, fontSize: 18),
        ),
        const SizedBox(height: 20),
        for (var index = 0;
            index < PartnerOnboardingController.identityDocuments.length;
            index++) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.selectDocument(index),
            child: Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: PartnerDecoration.field(),
              child: Row(
                children: [
                  Icon(_icons[index], size: 30, color: PartnerPalette.black),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      PartnerOnboardingController.identityDocuments[index],
                      style: const TextStyle(
                        color: PartnerPalette.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: PartnerPalette.mutedStrong,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

/// Step 4b-iii — "Capture the front side" of the chosen document, or of the
/// activity licence when reached from "Verify your licence".
class IdentityCaptureStep extends StatelessWidget {
  const IdentityCaptureStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file != null) {
      await controller.uploadDocument(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedDocument.value;
      final isLicence = controller.capturingLicence.value;
      final preview = controller.capturedPreviewPath.value;
      final busy = controller.isUploadingDocument.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingStepHeading(
            title: isLicence
                ? 'Activity licence'
                : index == null
                    ? 'Capture your document'
                    : PartnerOnboardingController.identityDocuments[index],
            subtitle: 'Capture the front side',
            alignment: CrossAxisAlignment.start,
          ),
          Container(
            height: 240,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: PartnerPalette.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (preview.isNotEmpty)
                  Image.file(File(preview), fit: BoxFit.cover)
                else
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.crop_free,
                        size: 80,
                        color: PartnerPalette.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Capture the front side',
                        style: TextStyle(
                          color: PartnerPalette.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                if (busy)
                  const ColoredBox(
                    color: Color(0x88000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: PartnerPalette.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: PartnerPrimaryButton(
              label: 'Take a photo',
              expand: true,
              leading: const Icon(
                Icons.photo_camera_outlined,
                size: 20,
                color: PartnerPalette.white,
              ),
              onPressed: busy ? null : () => _pick(ImageSource.camera),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PartnerPrimaryButton(
              label: 'Upload from the gallery',
              expand: true,
              leading: const Icon(
                Icons.photo_library_outlined,
                size: 20,
                color: PartnerPalette.white,
              ),
              onPressed: busy ? null : () => _pick(ImageSource.gallery),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Only the TRIPTRIVA team sees this photo, to verify your listing.',
            style: TextStyle(color: PartnerPalette.mutedStrong, fontSize: 13),
          ),
        ],
      );
    });
  }
}
