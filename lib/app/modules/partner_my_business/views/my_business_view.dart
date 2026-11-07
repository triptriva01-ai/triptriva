import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_activity_card.dart';
import '../../../widgets/partner/partner_bottom_nav.dart';
import '../../../widgets/partner/partner_empty_state.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_shell_header.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/my_business_controller.dart';

/// Partner-side Page 05 — My Business.
class MyBusinessView extends GetView<MyBusinessController> {
  const MyBusinessView({super.key});

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
                // My Business has no sub-tabs; the filter row sits in the body.
                tabs: const [],
                selectedTab: 0,
                onTabSelected: (_) {},
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!controller.hasActivities) {
                  return PartnerEmptyState(
                    message: 'Currently no activities available\n'
                        "Click on the '+' sign to add a new activity",
                    action: PartnerPrimaryButton.add(
                      label: 'Add Activity',
                      onPressed: controller.addActivity,
                    ),
                  );
                }
                return _ActivityList(controller: controller);
              }),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(
          () => controller.hasActivities
              ? PartnerPrimaryButton.add(
                  label: 'Add Activity',
                  onPressed: controller.addActivity,
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

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.controller});

  final MyBusinessController controller;

  @override
  Widget build(BuildContext context) {
    // Built from inside the parent's Obx, but that scope has closed by now —
    // so the filter needs its own to react to changes.
    return Obx(() {
      final activities = controller.visibleActivities;
      final total = controller.activities.length;

      return ListView(
        padding: const EdgeInsets.fromLTRB(
          PartnerSizes.pagePadding,
          30,
          PartnerSizes.pagePadding,
          // Clears the floating "Add Activity" button.
          110,
        ),
        children: [
          // Wrap so the count drops below the filter on narrow screens.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _FilterDropdown(controller: controller),
              Text(
                'Total activities : $total',
                style: const TextStyle(
                  color: PartnerPalette.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          for (final activity in activities) ...[
            PartnerActivityCard(
              activity: activity,
              onTap: () => controller.openActivity(activity),
            ),
            const SizedBox(height: 10),
          ],
        ],
      );
    });
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.controller});

  final MyBusinessController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: controller.selectedFilter.value,
      onSelected: controller.selectFilter,
      itemBuilder: (context) => [
        for (var index = 0;
            index < MyBusinessController.filters.length;
            index++)
          PopupMenuItem(
            value: index,
            child: Text(MyBusinessController.filters[index]),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            MyBusinessController.filters[controller.selectedFilter.value],
            style: const TextStyle(
              color: PartnerPalette.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PartnerPalette.white,
              border: Border.all(color: PartnerPalette.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.visibleActivities.length}',
              style: const TextStyle(
                color: PartnerPalette.black,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: PartnerPalette.black,
          ),
        ],
      ),
    );
  }
}
