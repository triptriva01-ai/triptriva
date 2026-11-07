import 'package:flutter/material.dart';

/// Design tokens for the sticky bar at the foot of the product page and every
/// step of the booking flow.
abstract final class BookingBarTheme {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;

  static const disabled = Color(0xFFBABABA);
  static const note = Color(0xFFFF4800);
  static const caption = Color(0xFF7B7B7B);
  static const struck = Color(0xFF999999);

  static const buttonHeight = 60.0;
  static const buttonRadius = 40.0;

  static const prime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [green, blue],
  );

  /// The brand gradient at 20%, behind the cancellation note.
  static LinearGradient noteWash() {
    return LinearGradient(
      colors: [
        green.withValues(alpha: 0.2),
        blue.withValues(alpha: 0.2),
      ],
    );
  }

  static const label = TextStyle(
    color: white,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.18,
  );

  static const wideLabel = TextStyle(
    color: white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.15,
  );

  static const noteText = TextStyle(
    color: note,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.17,
  );

  static const priceCaption = TextStyle(
    color: caption,
    fontSize: 14,
    height: 1.14,
  );

  static const price = TextStyle(
    color: black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const originalPrice = TextStyle(
    color: struck,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.17,
    decoration: TextDecoration.lineThrough,
    decorationColor: struck,
  );
}

/// The sticky footer: an optional cancellation strip above a gradient call to
/// action, with an optional price block beside it.
///
/// Everything sizes to its content — a larger system font grows the bar
/// rather than clipping the label.
class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    required this.label,
    required this.onPressed,
    this.note,
    this.leadingIcon,
    this.trailingIcon = Icons.arrow_forward,
    this.priceCaption,
    this.price,
    this.originalPrice,
    this.onPriceTap,
    this.isPriceExpanded = false,
    this.enabled = true,
    super.key,
  });

  final String label;

  /// Null disables the button, which also greys it out.
  final VoidCallback? onPressed;

  /// "Free cancellation before 24 hours".
  final String? note;

  final IconData? leadingIcon;
  final IconData trailingIcon;

  /// "For Day Trip" — shown above the price when a price is given.
  final String? priceCaption;

  /// Formatted, e.g. "₹500". Null renders a full-width button instead.
  final String? price;
  final String? originalPrice;

  /// Opens the bill breakdown. Null hides the chevron.
  final VoidCallback? onPriceTap;
  final bool isPriceExpanded;

  final bool enabled;

  bool get _isEnabled => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (note != null && note!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: BookingBarTheme.noteWash()),
            child: Text(
              note!,
              textAlign: TextAlign.center,
              style: BookingBarTheme.noteText,
            ),
          ),
        Container(
          width: double.infinity,
          color: BookingBarTheme.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: price == null
                  ? _button(wide: true)
                  // Side by side when they fit, stacked when they do not —
                  // at 320 dp with a large system font the price and the
                  // button cannot share one line.
                  : Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [_priceBlock(), _button(wide: false)],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceBlock() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPriceTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priceCaption != null) ...[
            Text(
              priceCaption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BookingBarTheme.priceCaption,
            ),
            const SizedBox(height: 8),
          ],
          // Wraps rather than overflowing: at a large system font the struck
          // original price drops to its own line instead of being clipped.
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (originalPrice != null)
                Text(originalPrice!, style: BookingBarTheme.originalPrice),
              Text(price!, style: BookingBarTheme.price),
              if (onPriceTap != null)
                Icon(
                  isPriceExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 24,
                  color: BookingBarTheme.black,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button({required bool wide}) {
    final content = Row(
      mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18, color: BookingBarTheme.white),
          const SizedBox(width: 13),
        ],
        // Both variants get bounded constraints — the page for the wide
        // button, the Wrap run for the compact one — so the label can flex
        // and ellipsise rather than overflow.
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: wide
                ? BookingBarTheme.wideLabel
                : BookingBarTheme.label,
          ),
        ),
        const SizedBox(width: 12),
        Icon(trailingIcon, size: 18, color: BookingBarTheme.white),
      ],
    );

    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isEnabled ? onPressed : null,
      child: Container(
        // A minimum, not a cap.
        constraints: const BoxConstraints(
          minHeight: BookingBarTheme.buttonHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: _isEnabled ? BookingBarTheme.prime : null,
          color: _isEnabled ? null : BookingBarTheme.disabled,
          borderRadius: BorderRadius.circular(
            BookingBarTheme.buttonRadius,
          ),
        ),
        child: content,
      ),
    );

    return wide ? SizedBox(width: double.infinity, child: button) : button;
  }
}
