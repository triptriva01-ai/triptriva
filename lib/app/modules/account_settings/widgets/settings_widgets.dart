import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/partner/partner_page_header.dart';
import '../../../widgets/partner/partner_theme.dart';

/// White page with the back-arrow title bar used by every settings screen.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.title,
    required this.onBack,
    required this.child,
    this.bottom,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  /// Pinned below the scrolling content, e.g. a submit button.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: PartnerPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PartnerPalette.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              PartnerPageHeader(title: title, onBack: onBack),
              const SizedBox(height: 24),
              Expanded(child: child),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}

/// Grey rounded multi-line box — the Feedback and Support text areas.
class SettingsMessageBox extends StatelessWidget {
  const SettingsMessageBox({
    required this.controller,
    required this.hint,
    required this.maxLength,
    this.minHeight = 224,
    this.footer,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final double minHeight;

  /// Sits inside the box under the text, e.g. the Support "SUBMIT" bar.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        border: Border.all(color: PartnerPalette.black.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 6,
            maxLines: 10,
            maxLength: maxLength,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: PartnerStyle.fieldValue.copyWith(fontSize: 18),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: PartnerStyle.fieldValue.copyWith(
                fontSize: 18,
                color: const Color(0xFF727783),
              ),
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}

/// Outlined white card row with a title and a muted caption.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    this.caption,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String title;
  final String? caption;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Highlights the border with the brand green.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PartnerPalette.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 81),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? PartnerPalette.green : PartnerPalette.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: settingsTileTitle),
                    if (caption != null && caption!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(caption!, style: settingsTileCaption),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

const settingsTileTitle = TextStyle(
  color: PartnerPalette.black,
  fontSize: 16,
  fontWeight: FontWeight.w500,
  height: 1.19,
);

const settingsTileCaption = TextStyle(
  color: Color(0xFF989898),
  fontSize: 14,
  height: 1.14,
);

/// Gradient-filled check circle used as a selected radio.
class SettingsRadio extends StatelessWidget {
  const SettingsRadio({required this.selected, this.busy = false, super.key});

  final bool selected;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: selected ? PartnerGradients.prime : null,
        border: selected ? null : Border.all(color: PartnerPalette.border),
      ),
      child: selected
          ? const Icon(Icons.check, size: 13, color: PartnerPalette.white)
          : null,
    );
  }
}
