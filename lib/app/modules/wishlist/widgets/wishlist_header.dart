import 'package:flutter/material.dart';

import '../constants/wishlist_constants.dart';

/// Back arrow and the "Wishlist" title.
class WishlistHeader extends StatelessWidget {
  const WishlistHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const SizedBox(
            width: WishlistSizes.backButtonSize,
            height: WishlistSizes.backButtonSize,
            child: Icon(
              Icons.arrow_back_ios_new,
              size: WishlistSizes.backIconSize,
              color: WishlistPalette.black,
            ),
          ),
        ),
        const SizedBox(width: WishlistSizes.backToTitle),
        // Takes the rest of the row so a longer title ellipsises instead of
        // pushing past the edge of the screen.
        const Expanded(
          child: Text(
            WishlistStrings.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WishlistStyle.title,
          ),
        ),
      ],
    );
  }
}
