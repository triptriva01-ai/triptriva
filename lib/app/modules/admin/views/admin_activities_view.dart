import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/charts/donut_chart.dart';
import '../constants/admin_constants.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_cards.dart';
import '../widgets/admin_shell.dart';

/// Admin — activity approvals.
class AdminActivitiesView extends GetView<AdminActivitiesController> {
  const AdminActivitiesView({super.key});

  static const _sliceColours = [
    AdminPalette.green,
    AdminPalette.blue,
    AdminPalette.deepBlue,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdminShell(
        title: AdminStrings.financialHub,
        currentIndex: controller.currentTab.value,
        onTabSelected: controller.onTabSelected,
        header: Obx(
          () => _Tabs(
            showPending: controller.showPending.value,
            onAccepted: controller.showAccepted,
            onPending: controller.showPendingTab,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AdminSizes.pagePadding,
              16,
              AdminSizes.pagePadding,
              AdminSizes.listBottomPadding,
            ),
            children: [
              const AdminSectionTitle(AdminStrings.usersCategories),
              const SizedBox(height: 8),
              AdminCard(
                padding: 24,
                child: Obx(() {
                  final slices = _slices(controller.categories.toList());
                  final total = slices.fold<double>(
                    0,
                    (sum, slice) => sum + slice.value,
                  );

                  return Wrap(
                    spacing: AdminSizes.donutGap,
                    runSpacing: 20,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DonutChart(
                        slices: slices,
                        centreValue: '${total.round()}',
                        centreLabel: AdminStrings.total,
                      ),
                      SizedBox(
                        width: 140,
                        child: DonutLegend(slices: slices),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: AdminSizes.sectionGap),
              Obx(
                () => AdminFilterChips(
                  labels: AdminActivitiesController.categoryFilters,
                  selectedIndex: controller.selectedCategory.value,
                  onSelected: controller.selectCategory,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final activities = controller.activities.toList();
                if (activities.isEmpty) {
                  return const Text(
                    AdminStrings.empty,
                    style: AdminStyle.cardMeta,
                  );
                }

                final isPending = controller.showPending.value;
                return Column(
                  children: [
                    for (final activity in activities) ...[
                      AdminActivityCard(
                        activity: activity,
                        onTap: () => controller.openActivity(activity),
                        onReject: isPending
                            ? () => controller.reject(activity)
                            : null,
                      ),
                      const SizedBox(height: AdminSizes.listGap),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  List<DonutSlice> _slices(List<({String label, double value})> data) {
    return [
      for (var index = 0; index < data.length; index++)
        DonutSlice(
          label: data[index].label,
          value: data[index].value,
          color: _sliceColours[index % _sliceColours.length],
        ),
    ];
  }
}

/// "Accepted activity" / "Pending activity", the active one underlined with
/// the brand gradient.
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.showPending,
    required this.onAccepted,
    required this.onPending,
  });

  final bool showPending;
  final VoidCallback onAccepted;
  final VoidCallback onPending;

  @override
  Widget build(BuildContext context) {
    // Wraps so the two tabs stack rather than overflowing at a large font.
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 27,
      runSpacing: 12,
      children: [
        _Tab(
          label: AdminStrings.acceptedActivity,
          isActive: !showPending,
          onTap: onAccepted,
        ),
        _Tab(
          label: AdminStrings.pendingActivity,
          isActive: showPending,
          onTap: onPending,
        ),
      ],
    );
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
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: isActive ? AdminStyle.tabActive : AdminStyle.tab,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: AdminGradients.prime.createShader,
              child: text,
            )
          else
            text,
          if (isActive) ...[
            const SizedBox(height: 6),
            Container(
              height: 1,
              width: 149,
              decoration: const BoxDecoration(
                gradient: AdminGradients.prime,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
