import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../constants/account_settings_constants.dart';
import '../controllers/account_settings_controllers.dart';
import '../widgets/settings_widgets.dart';

// ─────────────────────────────── Feedback ───────────────────────────────

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: AccountSettingsStrings.feedbackTitle,
      onBack: controller.goBack,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: PartnerSizes.pagePadding,
        ),
        children: [
          SettingsMessageBox(
            controller: controller.message,
            hint: AccountSettingsStrings.feedbackHint,
            maxLength: AccountSettingsStrings.maxMessageLength,
            minHeight: 277,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _GradientOutlineButton(
                  label: AccountSettingsStrings.reset,
                  onPressed: controller.reset,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => PartnerPrimaryButton(
                    label: controller.isSending.value
                        ? '…'
                        : AccountSettingsStrings.enter,
                    height: 49,
                    expand: true,
                    onPressed:
                        controller.canSubmit ? controller.submit : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Outlined pill whose label carries the brand gradient ("Reset").
class _GradientOutlineButton extends StatelessWidget {
  const _GradientOutlineButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          constraints: const BoxConstraints(minHeight: 49),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD5D5D5)),
            borderRadius: BorderRadius.circular(40),
          ),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: PartnerGradients.prime.createShader,
            child: Text(
              label,
              style: const TextStyle(
                color: PartnerPalette.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Language ───────────────────────────────

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: AccountSettingsStrings.languageTitle,
      onBack: controller.goBack,
      child: Obx(() {
        // Read here, not in itemBuilder: ListView builds its rows lazily,
        // after this builder returns, so reads there are not tracked.
        final selected = controller.selected.value;
        final saving = controller.savingCode.value;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            PartnerSizes.pagePadding,
            0,
            PartnerSizes.pagePadding,
            30,
          ),
          itemCount: AccountSettingsConfig.languages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, index) {
            final language = AccountSettingsConfig.languages[index];
            final isSelected = selected == language.code;
            return SettingsTile(
              title: language.nativeName,
              caption: language.englishName,
              selected: isSelected,
              onTap: () => controller.choose(language.code),
              trailing: SettingsRadio(
                selected: isSelected,
                busy: saving == language.code,
              ),
            );
          },
        );
      }),
    );
  }
}

// ─────────────────────────── Customer support ───────────────────────────

class CustomerSupportView extends GetView<CustomerSupportController> {
  const CustomerSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: AccountSettingsStrings.supportTitle,
      onBack: controller.goBack,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          PartnerSizes.pagePadding,
          0,
          PartnerSizes.pagePadding,
          30,
        ),
        children: [
          const _SupportBanner(),
          const SizedBox(height: 38),
          SettingsMessageBox(
            controller: controller.problem,
            hint: AccountSettingsStrings.supportHint,
            maxLength: AccountSettingsStrings.maxMessageLength,
            footer: Obx(
              () => _SubmitBar(
                busy: controller.isSending.value,
                onTap: controller.submit,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final (index, line)
              in AccountSettingsConfig.supportLines.indexed) ...[
            if (index > 0) const SizedBox(height: 16),
            SettingsTile(
              title: line.label,
              onTap: () => controller.call(line),
              trailing: _CallBadge(
                color: index.isEven
                    ? PartnerPalette.headerGreen
                    : PartnerPalette.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stand-in for the call-centre photo in the design: brand-tinted panel with
/// a headset, so the page needs no bundled stock image.
class _SupportBanner extends StatelessWidget {
  const _SupportBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PartnerPalette.green.withValues(alpha: 0.15),
            PartnerPalette.blue.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: PartnerGradients.prime.createShader,
          child: const Icon(
            Icons.support_agent,
            size: 110,
            color: PartnerPalette.white,
          ),
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            gradient: PartnerGradients.prime,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PartnerPalette.white,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send, size: 20, color: Color(0xFFF5F1EE)),
                      SizedBox(width: 8),
                      Text(
                        AccountSettingsStrings.submit,
                        style: TextStyle(
                          color: Color(0xFFF5F1EE),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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

class _CallBadge extends StatelessWidget {
  const _CallBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          PartnerPalette.white.withValues(alpha: 0.8),
          color,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.call, size: 18, color: color),
    );
  }
}

// ─────────────────────────────── About ───────────────────────────────

/// Static "About" copy; the audience comes in as `Get.arguments`.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final audience = Get.arguments is AboutAudience
        ? Get.arguments as AboutAudience
        : AboutAudience.traveller;
    return SettingsPage(
      title: AccountSettingsStrings.aboutTitle,
      onBack: Get.back,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          PartnerSizes.pagePadding,
          0,
          PartnerSizes.pagePadding,
          40,
        ),
        child: Text(
          audience == AboutAudience.partner
              ? AboutContent.partner
              : AboutContent.traveller,
          style: const TextStyle(
            color: PartnerPalette.black,
            fontSize: 16,
            height: 1.56,
          ),
        ),
      ),
    );
  }
}
