import 'package:flutter/material.dart';

/// Design tokens for the white, softly tinted section card used by the
/// booking detail and listing detail screens.
abstract final class DetailCardTheme {
  static const green = Color(0xFF1F7A63);
  static const blue = Color(0xFF2D9CDB);
  static const white = Colors.white;
  static const black = Colors.black;

  static const radius = 30.0;
  static const padding = 22.0;
  static const sectionGap = 18.0;

  static const bulletSize = 10.0;
  static const bulletToLabel = 16.0;

  /// Card background: the brand gradient almost entirely washed out by white,
  /// leaving a faint tint at the very top edge.
  static const wash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.0001, 0.1827],
    colors: [Color(0x99FFFFFF), Color(0xD1FFFFFF), white],
  );

  /// Hairline that fades out towards both ends.
  static const rule = LinearGradient(
    colors: [Color(0x00000000), Color(0xFFB5B5B5), Color(0x00000000)],
  );

  static const title = TextStyle(
    color: black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const bullet = TextStyle(
    color: black,
    fontSize: 20,
    height: 1.15,
  );
}

/// The white, softly tinted card every section of a detail screen sits in.
class DetailCard extends StatelessWidget {
  const DetailCard({required this.child, this.title, super.key});

  final Widget child;

  /// Centred heading with a fading rule under it, e.g. "Our Facilities".
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DetailCardTheme.padding),
      decoration: BoxDecoration(
        gradient: DetailCardTheme.wash,
        borderRadius: BorderRadius.circular(DetailCardTheme.radius),
        boxShadow: [
          BoxShadow(
            color: DetailCardTheme.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Center(child: Text(title!, style: DetailCardTheme.title)),
            const SizedBox(height: DetailCardTheme.sectionGap),
            const FadingRule(),
            const SizedBox(height: DetailCardTheme.sectionGap),
          ],
          child,
        ],
      ),
    );
  }
}

/// Hairline that fades to transparent at both ends, used between card rows.
class FadingRule extends StatelessWidget {
  const FadingRule({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: DetailCardTheme.rule),
    );
  }
}

/// Dotted list item used by Facilities and Policies.
class BulletRow extends StatelessWidget {
  const BulletRow({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nudged down so the dot sits on the first line of wrapped text.
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: SizedBox(
            width: DetailCardTheme.bulletSize,
            height: DetailCardTheme.bulletSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: DetailCardTheme.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: DetailCardTheme.bulletToLabel),
        Expanded(child: Text(label, style: DetailCardTheme.bullet)),
      ],
    );
  }
}
