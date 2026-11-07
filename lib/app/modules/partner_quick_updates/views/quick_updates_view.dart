import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_bottom_nav.dart';
import '../../../widgets/partner/partner_empty_state.dart';
import '../../../widgets/partner/partner_shell_header.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../constants/quick_updates_constants.dart';
import '../controllers/quick_updates_controller.dart';
import '../widgets/quick_update_cards.dart';

/// Partner-side Page 03 / 3.1 — Quick Updates (slot allocation and pricing).
class QuickUpdatesView extends GetView<QuickUpdatesController> {
  const QuickUpdatesView({super.key});

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
                  QuickUpdatesStrings.pricesAndDiscount,
                  QuickUpdatesStrings.slotAllocation,
                ],
                selectedTab: controller.selectedTab.value.index,
                onTabSelected: controller.selectTabAt,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!controller.hasListings) {
                  return const PartnerEmptyState(
                    message: QuickUpdatesStrings.emptyMessage,
                  );
                }

                final showPricing = controller.selectedTab.value ==
                    QuickUpdateTab.pricesAndDiscount;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    PartnerSizes.pagePadding,
                    30,
                    PartnerSizes.pagePadding,
                    24,
                  ),
                  itemCount: controller.listings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final listing = controller.listings[index];
                    return showPricing
                        ? PricingCard(
                            listing: listing,
                            onEdit: () => controller.editPricing(listing),
                          )
                        : SlotAllocationCard(
                            listing: listing,
                            onEdit: () => controller.editAllocation(listing),
                          );
                  },
                );
              }),
            ),
          ],
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
