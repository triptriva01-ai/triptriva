import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/wishlist_constants.dart';
import '../controllers/wishlist_controller.dart';

/// The category dropdown and the search box, side by side.
///
/// Figma draws the two pills at 163 dp and 211 dp, which together are wider
/// than a 360 dp phone. They are laid out as flexible shares in that same
/// ratio instead, so they fill whatever width the device actually has.
class WishlistFilterBar extends StatelessWidget {
  const WishlistFilterBar({required this.controller, super.key});

  final WishlistController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 163, child: _CategoryPill(controller: controller)),
        const SizedBox(width: WishlistSizes.filterGap),
        Expanded(flex: 211, child: _SearchPill(controller: controller)),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.controller});

  final WishlistController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;

      return PopupMenuButton<String?>(
        onSelected: controller.selectCategory,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WishlistSizes.filterRadius),
        ),
        itemBuilder: (context) => <PopupMenuEntry<String?>>[
          const PopupMenuItem<String?>(child: Text('All')),
          for (final category in WishlistController.categories)
            PopupMenuItem<String?>(value: category, child: Text(category)),
        ],
        child: _Pill(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected ?? 'All',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WishlistStyle.filterLabel,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: WishlistSizes.caretSize,
                color: WishlistPalette.black,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.controller});

  final WishlistController controller;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: WishlistSizes.filterIconSize,
            color: WishlistPalette.black,
          ),
          const SizedBox(width: WishlistSizes.filterIconGap),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              style: WishlistStyle.searchHint.copyWith(
                color: WishlistPalette.black,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: WishlistStrings.searchHint,
                hintStyle: WishlistStyle.searchHint,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: WishlistSizes.filterIconGap),
          const Icon(
            Icons.tune,
            size: WishlistSizes.filterIconSize,
            color: WishlistPalette.black,
          ),
        ],
      ),
    );
  }
}

/// The rounded white pill both filters sit in.
class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // A minimum, not a fixed height: the pill grows with the system font
      // rather than clipping its label.
      constraints: const BoxConstraints(minHeight: WishlistSizes.filterHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: WishlistSizes.filterPaddingX,
        vertical: WishlistSizes.filterPaddingY,
      ),
      decoration: BoxDecoration(
        color: WishlistPalette.white,
        borderRadius: BorderRadius.circular(WishlistSizes.filterRadius),
        border: Border.all(color: WishlistPalette.border),
        boxShadow: WishlistShadows.filterPill,
      ),
      child: Center(child: child),
    );
  }
}
