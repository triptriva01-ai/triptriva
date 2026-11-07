import 'package:flutter/material.dart';

import 'partner_page_header.dart';
import 'partner_primary_button.dart';
import 'partner_theme.dart';

/// Chrome shared by every step of the "Add Activity" onboarding wizard:
/// "Save & Exit" and "Need help?" across the top, and a footer carrying
/// Back / progress / Next.
///
/// Steps supply only their own content, so the chrome stays identical as the
/// partner moves through the flow.
class PartnerWizardScaffold extends StatelessWidget {
  const PartnerWizardScaffold({
    required this.child,
    required this.onSaveAndExit,
    required this.onHelp,
    required this.onBack,
    required this.onNext,
    this.progressLabel,
    this.nextLabel = 'Next',
    this.showFooterNav = true,
    super.key,
  });

  final Widget child;
  final VoidCallback onSaveAndExit;
  final VoidCallback onHelp;
  final VoidCallback onBack;

  /// Null disables the Next button — used while a step is incomplete.
  final VoidCallback? onNext;

  /// e.g. "2 / 4". Hidden when null.
  final String? progressLabel;
  final String nextLabel;

  /// Full-width primary button instead of Back / progress / Next.
  final bool showFooterNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartnerPalette.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PartnerSizes.pagePadding,
                10,
                PartnerSizes.pagePadding,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PartnerOutlinedButton(
                    label: 'Save & Exit',
                    onPressed: onSaveAndExit,
                  ),
                  PartnerHelpLink(onTap: onHelp),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PartnerSizes.pagePadding,
                  24,
                  PartnerSizes.pagePadding,
                  24,
                ),
                child: child,
              ),
            ),
            _WizardFooter(
              onBack: onBack,
              onNext: onNext,
              progressLabel: progressLabel,
              nextLabel: nextLabel,
              showNav: showFooterNav,
            ),
          ],
        ),
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({
    required this.onBack,
    required this.onNext,
    required this.progressLabel,
    required this.nextLabel,
    required this.showNav,
  });

  final VoidCallback onBack;
  final VoidCallback? onNext;
  final String? progressLabel;
  final String nextLabel;
  final bool showNav;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PartnerPalette.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Color(0x40000000), blurRadius: 1, offset: Offset(0, -1)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 9, 20, 21),
          child: showNav
              ? Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBack,
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Color(0xFF2C2C2C),
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          progressLabel ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PartnerPalette.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Flexible so a long label ("Get started", "Publish")
                    // shrinks rather than pushing the row past the screen.
                    Flexible(
                      child: PartnerPrimaryButton(
                        label: nextLabel,
                        onPressed: onNext,
                        trailing: const Icon(
                          Icons.arrow_forward,
                          size: 19,
                          color: PartnerPalette.white,
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: PartnerPrimaryButton(
                    label: nextLabel,
                    onPressed: onNext,
                    expand: true,
                  ),
                ),
        ),
      ),
    );
  }
}
