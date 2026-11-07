import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/app_bottom_nav.dart';
import '../constants/reservations_constants.dart';
import '../controllers/reservations_controller.dart';
import '../widgets/booking_card.dart';
import '../widgets/reservations_header.dart';
import '../widgets/reservations_search_bar.dart';

/// Page 2 — Reservations.
class ReservationsView extends GetView<ReservationsController> {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: ReservationsPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ReservationsPalette.white,
        body: Column(
          children: [
            ReservationsHeader(controller: controller),
            const SizedBox(height: ReservationsSizes.headerToSearch),
            ReservationsSearchBar(controller: controller),
            const SizedBox(height: ReservationsSizes.searchToList),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groups = controller.visibleGroups;
                if (groups.isEmpty) {
                  return const Center(
                    child: Text(
                      ReservationsStrings.emptyMessage,
                      style: ReservationsStyle.empty,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadBookings,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      ReservationsSizes.pagePadding,
                      0,
                      ReservationsSizes.pagePadding,
                      ReservationsSizes.listBottomPadding,
                    ),
                    children: [
                      for (final group in groups) ...[
                        Text(
                          group.label,
                          style: ReservationsStyle.groupLabel,
                        ),
                        const SizedBox(
                          height: ReservationsSizes.groupLabelToCards,
                        ),
                        for (final booking in group.bookings) ...[
                          BookingCard(
                            booking: booking,
                            onTap: () => controller.openBooking(booking),
                          ),
                          const SizedBox(height: ReservationsSizes.cardGap),
                        ],
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: Obx(
          () => AppBottomNav(
            currentIndex: controller.currentTab.value,
            onTap: controller.onTabSelected,
          ),
        ),
      ),
    );
  }
}
