import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/reservations_constants.dart';
import '../controllers/reservations_controller.dart';

/// White header sheet with the page title and the All / Booked / Completed
/// tabs (FR-01).
class ReservationsHeader extends StatelessWidget {
  const ReservationsHeader({required this.controller, super.key});

  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ReservationsPalette.white,
        border: Border(
          bottom: BorderSide(color: ReservationsPalette.border),
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(ReservationsSizes.headerRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: ReservationsSizes.titleTop),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ReservationsSizes.pagePadding,
              ),
              child: Text(
                ReservationsStrings.title,
                style: ReservationsStyle.pageTitle,
              ),
            ),
            const SizedBox(height: ReservationsSizes.titleToTabs),
            Obx(() {
              final selected = controller.selectedFilter.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final filter in BookingFilter.values)
                    _Tab(
                      label: _labelFor(filter),
                      isActive: selected == filter,
                      onTap: () => controller.selectFilter(filter),
                    ),
                ],
              );
            }),
            const SizedBox(height: ReservationsSizes.pagePadding),
          ],
        ),
      ),
    );
  }

  String _labelFor(BookingFilter filter) {
    return switch (filter) {
      BookingFilter.all => ReservationsStrings.tabAll,
      BookingFilter.booked => ReservationsStrings.tabBooked,
      BookingFilter.completed => ReservationsStrings.tabCompleted,
    };
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: ReservationsGradients.prime.createShader,
              child: Text(label, style: ReservationsStyle.tabActive),
            )
          else
            Text(label, style: ReservationsStyle.tabInactive),
          const SizedBox(height: ReservationsSizes.tabToUnderline),
          Container(
            width: ReservationsSizes.underlineWidth,
            height: ReservationsSizes.underlineHeight,
            decoration: BoxDecoration(
              gradient: isActive ? ReservationsGradients.prime : null,
              borderRadius: BorderRadius.circular(
                ReservationsSizes.underlineRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
