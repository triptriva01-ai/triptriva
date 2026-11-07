import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/banner_item.dart';
import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';

/// FR-05 — swipeable, auto-sliding promotional banner carousel with a page
/// indicator.
class BannerCarousel extends StatelessWidget {
  const BannerCarousel({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banners = controller.banners;
      if (banners.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          SizedBox(
            height: HomeSizes.bannerHeight,
            child: PageView.builder(
              controller: controller.bannerPageController,
              onPageChanged: controller.onBannerChanged,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HomeSizes.bannerGap / 2,
                  ),
                  child: _BannerCard(
                    banner: banners[index],
                    onBookNow: () => controller.openBanner(banners[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: HomeSizes.bannerToDots),
          _Dots(controller: controller, count: banners.length),
        ],
      );
    });
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onBookNow});

  final BannerItem banner;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeSizes.bannerRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (banner.imageUrl.isEmpty)
            const ColoredBox(color: HomePalette.imagePlaceholder)
          else
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: HomePalette.imagePlaceholder),
            ),
          Positioned(
            left: HomeSizes.bannerLabelInset,
            top: HomeSizes.bannerLabelInset,
            child: Text(banner.title, style: HomeStyle.bannerTitle),
          ),
          Positioned(
            right: HomeSizes.overlayInset + 8,
            bottom: HomeSizes.overlayInset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: HomeGradients.prime,
                borderRadius: BorderRadius.circular(HomeSizes.bookNowRadius),
                boxShadow: HomeShadows.bookNow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBookNow,
                  borderRadius: BorderRadius.circular(
                    HomeSizes.bookNowRadius,
                  ),
                  child: SizedBox(
                    width: HomeSizes.bookNowWidth,
                    height: HomeSizes.bookNowHeight,
                    child: Center(
                      child: Text(banner.ctaLabel, style: HomeStyle.bookNow),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.controller, required this.count});

  final HomeController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentBanner.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++) ...[
            if (index > 0) const SizedBox(width: HomeSizes.dotGap),
            _Dot(isActive: index == current),
          ],
        ],
      );
    });
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final size = isActive ? HomeSizes.activeDotSize : HomeSizes.dotSize;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isActive ? HomeGradients.prime : HomeGradients.inactiveDot,
        shape: BoxShape.circle,
      ),
    );
  }
}
