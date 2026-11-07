import 'package:flutter/material.dart';

import 'partner_theme.dart';

/// Back chevron plus screen title, used by every partner detail screen that
/// pushes on top of the tabbed shell.
class PartnerPageHeader extends StatelessWidget {
  const PartnerPageHeader({
    required this.title,
    required this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PartnerSizes.pagePadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.only(right: 16, top: 4, bottom: 4),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: PartnerPalette.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PartnerStyle.pageTitle,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// "Need help?" link shown top-right on the onboarding wizard.
class PartnerHelpLink extends StatelessWidget {
  const PartnerHelpLink({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline, size: 18, color: PartnerPalette.link),
          SizedBox(width: 9),
          Text('Need help?', style: PartnerStyle.footerLink),
        ],
      ),
    );
  }
}
