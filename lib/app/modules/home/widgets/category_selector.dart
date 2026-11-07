import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';

/// FR-04 — category navigation (Stay / House Boat / Adventure). The selected
/// category sits on a brand-tinted chip that fades to white.
class CategorySelector extends StatelessWidget {
  const CategorySelector({required this.controller, super.key});

  final HomeController controller;

  // TODO(design): replace with the artwork PNGs from the Figma file.
  static const _icons = <IconData>[
    Icons.holiday_village,
    Icons.directions_boat,
    Icons.paragliding,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeSizes.categoryHeight,
      child: Obx(() {
        final selected = controller.selectedCategory.value;
        return Row(
          children: [
            for (var index = 0; index < controller.categories.length; index++)
              Expanded(
                child: _CategoryItem(
                  icon: _icons[index],
                  label: controller.categories[index],
                  isActive: selected == index,
                  onTap: () => controller.selectCategory(index),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: HomeSizes.categoryIconSize,
          color: isActive ? HomePalette.green : HomePalette.categoryInactive,
        ),
        const SizedBox(height: HomeSizes.categoryIconToLabel),
        isActive
            ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: HomeGradients.prime.createShader,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: HomeStyle.categoryActive,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: HomeStyle.categoryInactive,
              ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: isActive
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: HomeGradients.categoryBrand,
                borderRadius: BorderRadius.circular(HomeSizes.categoryRadius),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: HomeGradients.categoryWhiteFade(),
                  borderRadius: BorderRadius.circular(
                    HomeSizes.categoryRadius,
                  ),
                ),
                child: Center(child: content),
              ),
            )
          : Center(child: content),
    );
  }
}
