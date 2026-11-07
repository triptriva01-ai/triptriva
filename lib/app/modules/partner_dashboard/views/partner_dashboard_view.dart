import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_booking_card.dart';
import '../../../widgets/partner/partner_bottom_nav.dart';
import '../../../widgets/partner/partner_empty_state.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_shell_header.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../constants/partner_dashboard_constants.dart';
import '../controllers/partner_dashboard_controller.dart';

/// Partner-side Page 02 — Reservation dashboard.
class PartnerDashboardView extends GetView<PartnerDashboardController> {
  const PartnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: PartnerPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PartnerPalette.white,
        body: Column(
          children: [
            Obx(
              () => PartnerShellHeader(
                name: controller.partnerName.value,
                onNotificationsTap: controller.openNotifications,
                onProfileTap: controller.openProfile,
                tabs: const [
                  PartnerStrings.todayBookings,
                  PartnerStrings.allBookings,
                ],
                selectedTab: controller.selectedBookingTab.value.index,
                onTabSelected: controller.selectBookingTabAt,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!controller.hasBookings) {
                  return PartnerEmptyState(
                    message: PartnerStrings.emptyMessage,
                    action: PartnerPrimaryButton.add(
                      label: PartnerStrings.addManualSlot,
                      onPressed: controller.addManualSlot,
                    ),
                  );
                }
                return _BookingList(controller: controller);
              }),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(
          () => controller.hasBookings
              ? PartnerPrimaryButton.add(
                  label: PartnerStrings.addManualSlot,
                  onPressed: controller.addManualSlot,
                )
              : const SizedBox.shrink(),
        ),
        bottomNavigationBar: Obx(
          () => PartnerBottomNav(
            currentIndex: controller.currentTab.value,
            onTap: controller.onTabSelected,
          ),
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.controller});

  final PartnerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    // This widget is built from inside the parent's Obx, but that scope has
    // already closed by the time `build` runs — so it needs its own.
    return Obx(() {
      // Snapshot every observable here. `itemBuilder` is called lazily as the
      // list scrolls, outside this scope, so it must not read them directly.
      final bookings = controller.visibleBookings;
      final selectedCategory = controller.selectedCategory.value;
      // Read so this scope rebuilds when a guest is checked in.
      controller.confirmedIds.length;

      return Column(
        children: [
          const SizedBox(height: 30),
          PartnerCategoryChips(
            categories: PartnerDashboardController.categories,
            selectedIndex: selectedCategory,
            onSelected: controller.selectCategory,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: bookings.isEmpty
                ? const Center(
                    child: Text(
                      'No bookings in this category',
                      style: PartnerStyle.rowCaption,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      PartnerSizes.pagePadding,
                      0,
                      PartnerSizes.pagePadding,
                      // Clears the floating "Add Manual Slot" button.
                      110,
                    ),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return PartnerBookingCard(
                        booking: booking,
                        customerName: booking.guestName,
                        onConfirm: controller.isConfirmed(booking)
                            ? null
                            : () => controller.confirmBooking(booking),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
