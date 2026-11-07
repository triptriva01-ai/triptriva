import 'package:flutter/material.dart';

import '../constants/reservations_constants.dart';
import '../controllers/reservations_controller.dart';

/// Search field plus the date-filter calendar button.
class ReservationsSearchBar extends StatelessWidget {
  const ReservationsSearchBar({required this.controller, super.key});

  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReservationsSizes.pagePadding,
      ),
      child: Container(
        height: ReservationsSizes.searchHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: ReservationsPalette.white,
          border: Border.all(color: ReservationsPalette.border),
          borderRadius: BorderRadius.circular(ReservationsSizes.searchRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: ReservationsSizes.searchIconSize,
              color: ReservationsPalette.black,
            ),
            const SizedBox(width: ReservationsSizes.searchIconToLabel),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                style: ReservationsStyle.searchInput,
                cursorColor: ReservationsPalette.green,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: ReservationsStrings.searchHint,
                  hintStyle: ReservationsStyle.searchInput,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.openDateFilter,
              child: const Icon(
                Icons.calendar_today,
                size: ReservationsSizes.searchIconSize,
                color: ReservationsPalette.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
