import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';
import 'home_filter_panels.dart';

/// FR-06 (filters), FR-07 (date selection) and FR-08 (price range).
///
/// Each chip opens its pop-up just under the row, floating over the
/// listings; tapping outside or on the close button dismisses it.
class FilterRow extends StatefulWidget {
  const FilterRow({required this.controller, super.key});

  final HomeController controller;

  @override
  State<FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<FilterRow> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  late final Worker _worker;

  HomeController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _worker = ever<HomeFilterPanel?>(controller.openPanel, (panel) {
      if (!mounted) return;
      panel == null ? _portal.hide() : _portal.show();
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildPanel,
      child: CompositedTransformTarget(
        link: _link,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSizes.pagePadding,
          ),
          child: Obx(() {
            final open = controller.openPanel.value;
            return Row(
              children: [
                _FilterChip(
                  icon: Icons.tune,
                  isActive: open == HomeFilterPanel.filter ||
                      controller.selectedCapacity.value != null,
                  onTap: controller.openFilters,
                ),
                const SizedBox(width: HomeSizes.filterGap),
                Expanded(
                  child: _FilterChip(
                    icon: Icons.calendar_today,
                    label: controller.dateLabel,
                    isActive: open == HomeFilterPanel.calendar,
                    hasValue: controller.selectedDate.value != null,
                    onTap: controller.openDatePicker,
                  ),
                ),
                const SizedBox(width: HomeSizes.filterGap),
                Expanded(
                  child: _FilterChip(
                    icon: Icons.local_offer_outlined,
                    label: controller.priceLabel,
                    isActive: open == HomeFilterPanel.price,
                    hasValue: controller.selectedPrice.value != null,
                    onTap: controller.openPriceRange,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return Obx(() {
      final panel = controller.openPanel.value;
      if (panel == null) return const SizedBox.shrink();

      final alignRight = panel == HomeFilterPanel.price;
      final child = switch (panel) {
        HomeFilterPanel.filter => FilterPanel(controller: controller),
        HomeFilterPanel.calendar => CalendarPanel(controller: controller),
        HomeFilterPanel.price => PricePanel(controller: controller),
      };

      return Stack(
        children: [
          // Tap anywhere else to dismiss.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.closePanel,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            targetAnchor: alignRight ? Alignment.bottomRight : Alignment.bottomLeft,
            followerAnchor: alignRight ? Alignment.topRight : Alignment.topLeft,
            offset: Offset(
              alignRight ? -HomeSizes.pagePadding : HomeSizes.pagePadding,
              HomeSizes.panelGap,
            ),
            child: Align(
              alignment: alignRight ? Alignment.topRight : Alignment.topLeft,
              child: child,
            ),
          ),
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.onTap,
    this.label,
    this.isActive = false,
    this.hasValue = false,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  /// Its pop-up is open (or, for the filter chip, a filter is applied).
  final bool isActive;

  /// A value is picked, so the label reads as content, not a hint.
  final bool hasValue;

  @override
  Widget build(BuildContext context) {
    final highlighted = isActive || hasValue;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomePalette.white,
        border: Border.all(
          color: highlighted ? HomePalette.green : HomePalette.border,
        ),
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
                    color: highlighted ? HomePalette.green : HomePalette.black,
                  ),
                  if (label != null) ...[
                    const SizedBox(width: HomeSizes.filterIconToLabel),
                    Flexible(
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: highlighted
                            ? HomeStyle.filterLabelActive
                            : HomeStyle.filterLabel,
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
