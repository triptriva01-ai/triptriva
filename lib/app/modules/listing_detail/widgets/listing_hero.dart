import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/listing_detail_constants.dart';
import '../controllers/listing_detail_controller.dart';

/// The photo behind the top of the page, with the back / share / wishlist
/// buttons over it and the carousel dots at its foot.
class ListingHero extends StatelessWidget {
  const ListingHero({required this.controller, super.key});

  final ListingDetailController controller;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      // A bounded box holding an image and a few overlays, never text.
      height: ListingDetailSizes.heroHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final images = controller.detail.value?.imageUrls ?? const [];
              if (images.isEmpty) {
                return const _HeroPlaceholder();
              }
              return PageView.builder(
                onPageChanged: controller.selectImage,
                itemCount: images.length,
                itemBuilder: (context, index) => Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _HeroPlaceholder(),
                ),
              );
            }),
          ),
          Positioned(
            left: ListingDetailSizes.headerInset,
            top: topInset + 12,
            child: _CircleButton(
              icon: Icons.arrow_back_ios_new,
              onTap: controller.goBack,
            ),
          ),
          Positioned(
            right: ListingDetailSizes.headerInset,
            top: topInset + 12,
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.ios_share,
                  onTap: controller.share,
                ),
                const SizedBox(width: ListingDetailSizes.circleButtonGap),
                Obx(
                  () => _CircleButton(
                    icon: controller.isWishlisted.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onTap: controller.toggleWishlist,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: ListingDetailSizes.dotsBottomInset,
            child: Obx(() {
              final images = controller.detail.value?.imageUrls ?? const [];
              final current = controller.currentImage.value;
              if (images.length < 2) {
                return const SizedBox.shrink();
              }
              return _Dots(count: images.length, current: current);
            }),
          ),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: ListingDetailPalette.placeholder,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: ListingDetailPalette.white,
          size: 48,
        ),
      ),
    );
  }
}

/// White circle with a soft shadow, used for back / share / wishlist.
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: ListingDetailSizes.circleButtonSize,
        height: ListingDetailSizes.circleButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ListingDetailPalette.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ListingDetailPalette.black.withValues(alpha: 0.25),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: ListingDetailSizes.circleIconSize,
          color: ListingDetailPalette.black,
        ),
      ),
    );
  }
}

/// Carousel position: the active page is a stadium, the rest are circles.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: ListingDetailSizes.dotGap,
      runSpacing: 8,
      children: [
        for (var index = 0; index < count; index++)
          Container(
            width: index == current
                ? ListingDetailSizes.activeDotWidth
                : ListingDetailSizes.dotSize,
            height: ListingDetailSizes.dotSize,
            decoration: BoxDecoration(
              color: ListingDetailPalette.white.withValues(
                alpha: index == current ? 1 : 0.6,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
      ],
    );
  }
}
