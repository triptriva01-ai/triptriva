import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/charts/donut_chart.dart';
import '../../../widgets/charts/revenue_chart.dart';
import '../constants/admin_constants.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_cards.dart';
import '../widgets/admin_shell.dart';

/// Admin — Revenue dashboard.
class AdminRevenueView extends GetView<AdminRevenueController> {
  const AdminRevenueView({super.key});

  static const _sliceColours = [
    AdminPalette.green,
    AdminPalette.blue,
    AdminPalette.deepBlue,
  ];

  static const _valueColours = [
    AdminPalette.tealDark,
    AdminPalette.blueDark,
    AdminPalette.deepBlue,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdminShell(
        title: AdminStrings.revenue,
        wash: true,
        currentIndex: controller.currentTab.value,
        onTabSelected: controller.onTabSelected,
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AdminSizes.pagePadding,
              0,
              AdminSizes.pagePadding,
              AdminSizes.listBottomPadding,
            ),
            children: [
              Obx(() {
                final summary = controller.summary.value;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: AdminStrings.thisMonthTotal,
                        value: AdminBaseController.formatRupees(
                          summary.monthTotal,
                        ),
                        trendPercent: summary.monthGrowthPercent,
                      ),
                    ),
                    const SizedBox(width: AdminSizes.listGap),
                    Expanded(
                      child: AdminStatCard(
                        label: AdminStrings.yearTotal,
                        value: AdminBaseController.formatRupees(
                          summary.yearTotal,
                        ),
                        caption: AdminStrings.bookingsCount(
                          summary.bookingCount,
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: AdminSizes.sectionGap),
              const AdminSectionTitle(AdminStrings.incomeGrowth),
              const SizedBox(height: 8),
              AdminCard(
                child: Obx(() {
                  final points = controller.curve.toList();
                  return RevenueChart(
                    values: [for (final point in points) point.value],
                    labels: [for (final point in points) point.label],
                    highlightIndex:
                        points.isEmpty ? null : points.length - 1,
                  );
                }),
              ),
              const SizedBox(height: AdminSizes.sectionGap),
              const AdminSectionTitle(AdminStrings.incomeCategories),
              const SizedBox(height: 8),
              AdminCard(
                padding: 24,
                child: Obx(() {
                  final slices = _slices(controller.categories.toList());
                  final total = slices.fold<double>(
                    0,
                    (sum, slice) => sum + slice.value,
                  );

                  // Wraps so the ring and its legend stack instead of
                  // overflowing on a narrow phone.
                  return Wrap(
                    spacing: AdminSizes.donutGap,
                    runSpacing: 20,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DonutChart(
                        slices: slices,
                        centreValue:
                            AdminBaseController.formatRupees(total),
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
              const AdminSectionTitle(AdminStrings.bookings),
              const SizedBox(height: 20),
              Obx(
                () => AdminFilterChips(
                  labels: AdminRevenueController.categoryFilters,
                  selectedIndex: controller.selectedCategory.value,
                  onSelected: controller.selectCategory,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = controller.bookings.toList();
                if (bookings.isEmpty) {
                  return const Text(
                    AdminStrings.empty,
                    style: AdminStyle.cardMeta,
                  );
                }
                return Column(
                  children: [
                    for (final booking in bookings) ...[
                      AdminBookingCard(
                        booking: booking,
                        onTap: () => controller.openBooking(booking),
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
          valueColor: _valueColours[index % _valueColours.length],
          displayValue:
              AdminBaseController.formatRupees(data[index].value),
        ),
    ];
  }
}
