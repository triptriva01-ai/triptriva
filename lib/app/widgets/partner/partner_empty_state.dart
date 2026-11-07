import 'package:flutter/material.dart';

import 'partner_theme.dart';

/// Shared partner empty state: illustration, gradient "Empty" headline, a
/// supporting message and an optional call to action.
class PartnerEmptyState extends StatelessWidget {
  const PartnerEmptyState({
    required this.message,
    this.title = 'Empty',
    this.action,
    super.key,
  });

  final String message;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // Nudges the block above the true centre, matching the Figma layout.
        padding: const EdgeInsets.only(
          bottom: PartnerSizes.emptyStateBottomBias,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO(design): swap for the `folder_11329073.png` illustration.
            const Icon(
              Icons.folder_open_rounded,
              size: PartnerSizes.illustrationSize,
              color: PartnerPalette.headerGreen,
            ),
            const SizedBox(height: PartnerSizes.illustrationToTitle),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: PartnerGradients.prime.createShader,
              child: Text(title, style: PartnerStyle.emptyTitle),
            ),
            const SizedBox(height: PartnerSizes.titleToMessage),
            Text(
              message,
              textAlign: TextAlign.center,
              style: PartnerStyle.emptyMessage,
            ),
            if (action != null) ...[
              const SizedBox(height: PartnerSizes.messageToAction),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
