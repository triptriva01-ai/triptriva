import 'package:flutter/material.dart';

import 'partner_theme.dart';

/// Gradient pill button used for every primary partner action.
///
/// [leading] renders the white circular badge seen on "Add Manual Slot" and
/// "Add Activity"; [trailing] renders the forward chevron on wizard buttons.
class PartnerPrimaryButton extends StatelessWidget {
  const PartnerPrimaryButton({
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.expand = false,
    this.height = 60,
    super.key,
  });

  /// Convenience constructor for the white "+" badge variant.
  factory PartnerPrimaryButton.add({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
  }) {
    return PartnerPrimaryButton(
      key: key,
      label: label,
      onPressed: onPressed,
      height: 54,
      leading: const _AddBadge(),
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;

  /// Stretches to the available width instead of hugging its content.
  final bool expand;
  final double height;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: PartnerStyle.actionButton.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    return Opacity(
      // Disabled buttons in the Figma export are flat grey rather than faded,
      // but the gradient is what identifies the primary action.
      opacity: _isEnabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(110),
          child: Ink(
            decoration: BoxDecoration(
              gradient: _isEnabled ? PartnerGradients.prime : null,
              color: _isEnabled ? null : PartnerPalette.disabled,
              borderRadius: BorderRadius.circular(110),
            ),
            child: ConstrainedBox(
              // `height` is the design height but only a minimum here, so a
              // larger system font makes the button taller, never clipped.
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: leading == null ? 42 : 14,
                  vertical: 8,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddBadge extends StatelessWidget {
  const _AddBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: PartnerPalette.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: PartnerGradients.prime.createShader,
          child: const Icon(Icons.add, size: 16, color: PartnerPalette.white),
        ),
      ),
    );
  }
}

/// Secondary pill: outlined, used for "Save & Exit" and "view similar listing".
class PartnerOutlinedButton extends StatelessWidget {
  const PartnerOutlinedButton({
    required this.label,
    required this.onPressed,
    this.height = 41,
    this.radius = 20,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: PartnerPalette.borderStrong),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PartnerStyle.fieldValue.copyWith(height: 1.19),
          ),
        ),
      ),
    );
  }
}
