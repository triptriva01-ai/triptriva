import 'package:flutter/material.dart';

import 'partner_theme.dart';

/// Rounded outlined text field with the label sitting inside the pill, the
/// pattern used throughout the onboarding wizard.
class PartnerTextField extends StatelessWidget {
  const PartnerTextField({
    required this.hint,
    this.controller,
    this.label,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;

  /// Small grey caption above the value once the field has content.
  final String? label;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: PartnerDecoration.field(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                label!,
                style: const TextStyle(
                  color: PartnerPalette.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: PartnerStyle.fieldValue,
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              border: InputBorder.none,
              hintText: hint,
              hintStyle: PartnerStyle.fieldLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Label on the left, a `−  n  +` stepper on the right. Used for guests,
/// bedrooms, beds and bathrooms.
class PartnerCounterRow extends StatelessWidget {
  const PartnerCounterRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
  });

  final String label;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: PartnerStyle.rowLabel)),
        _RoundIconButton(icon: Icons.remove, onTap: onDecrement),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: PartnerPalette.black),
          ),
        ),
        _RoundIconButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            // The gradient sits under a white wash, giving the pale tint in
            // the Figma export.
            gradient: PartnerGradients.prime,
            shape: BoxShape.circle,
          ),
          foregroundDecoration: BoxDecoration(
            color: PartnerPalette.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: PartnerPalette.black),
        ),
      ),
    );
  }
}

/// Selectable card used for activity type, facilities and booking type.
class PartnerOptionCard extends StatelessWidget {
  const PartnerOptionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.description,
    this.axis = Axis.horizontal,
    this.height = 120,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  /// Supporting copy under the label; only used by the booking-type cards.
  final String? description;

  /// Horizontal puts the icon beside the label, vertical stacks them.
  final Axis axis;
  final double height;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 30, color: PartnerPalette.headingDark);
    final labelWidget = Text(
      label,
      textAlign: axis == Axis.vertical ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        color: PartnerPalette.headingDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        // Minimum, not fixed: the card grows for a long label or a large
        // system font rather than clipping its contents.
        constraints:
            description == null ? BoxConstraints(minHeight: height) : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PartnerPalette.white,
          border: Border.all(
            // Selection is shown by dropping the outline, matching Figma.
            color: selected ? Colors.transparent : PartnerPalette.borderStrong,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: PartnerPalette.green.withValues(alpha: 0.18),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: description != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: PartnerPalette.black),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(label, style: PartnerStyle.formHeading),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description!,
                    style: const TextStyle(
                      color: PartnerPalette.mutedStrong,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Center(
                child: axis == Axis.horizontal
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          iconWidget,
                          const SizedBox(width: 12),
                          Flexible(child: labelWidget),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          iconWidget,
                          const SizedBox(height: 12),
                          labelWidget,
                        ],
                      ),
              ),
      ),
    );
  }
}

/// Row with a title, optional caption and a bordered value box on the right —
/// the discount and season-percentage rows.
class PartnerValueRow extends StatelessWidget {
  const PartnerValueRow({
    required this.title,
    required this.value,
    this.caption,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: PartnerPalette.black,
                  fontSize: 22,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 12),
                Text(caption!, style: PartnerStyle.rowCaption),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 102, minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: PartnerPalette.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: PartnerPalette.black,
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
