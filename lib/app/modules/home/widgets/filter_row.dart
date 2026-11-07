import 'package:flutter/material.dart';

import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';

/// FR-06 (filters), FR-07 (date selection) and FR-08 (price range).
class FilterRow extends StatelessWidget {
  const FilterRow({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeSizes.pagePadding),
      child: Row(
        children: [
          _FilterChip(
            icon: Icons.tune,
            onTap: controller.openFilters,
          ),
          const SizedBox(width: HomeSizes.filterGap),
          Expanded(
            child: _FilterChip(
              icon: Icons.calendar_today,
              label: HomeStrings.datePlaceholder,
              onTap: controller.openDatePicker,
            ),
          ),
          const SizedBox(width: HomeSizes.filterGap),
          Expanded(
            child: _FilterChip(
              icon: Icons.local_offer_outlined,
              label: HomeStrings.priceRange,
              onTap: controller.openPriceRange,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomePalette.white,
        border: Border.all(color: HomePalette.border),
        borderRadius: BorderRadius.circular(HomeSizes.filterRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HomeSizes.filterRadius),
          child: SizedBox(
            height: HomeSizes.filterHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: label == null ? 19 : 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: HomeSizes.filterIconSize,
                    color: HomePalette.black,
                  ),
                  if (label != null) ...[
                    const SizedBox(width: HomeSizes.filterIconToLabel),
                    Flexible(
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: HomeStyle.filterLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
