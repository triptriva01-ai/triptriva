import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_bottom_nav.dart';
import '../../../widgets/partner/partner_shell_header.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/revenue_controller.dart';
import '../../../widgets/charts/revenue_chart.dart';

/// Partner-side Page 04 — Revenue.
class RevenueView extends GetView<RevenueController> {
  const RevenueView({super.key});

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
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    PartnerSizes.pagePadding,
                    24,
                    PartnerSizes.pagePadding,
                    24,
                  ),
                  children: [
                    IntrinsicHeight(
                      // Keeps the pair level whichever figure is taller.
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'This month total',
                            value: RevenueController.formatRupees(
                              controller.monthTotal.value,
                            ),
                            footer: _ChangeFooter(
                              percent: controller.monthChangePercent.value,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _MetricCard(
                            label: 'Year total',
                            value: RevenueController.formatRupees(
                              controller.yearTotal.value,
                            ),
                            footer: Text(
                              '${controller.yearBookings.value} Bookings',
                              style: PartnerStyle.metricLabel,
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 17),
                    _ChartCard(controller: controller),
                    const SizedBox(height: 20),
                    const Text('Bookings', style: PartnerStyle.sectionTitle),
                    const SizedBox(height: 20),
                    if (controller.entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No bookings in this period',
                            style: PartnerStyle.rowCaption,
                          ),
                        ),
                      )
                    else ...[
                      for (final entry in controller.visibleEntries) ...[
                        _RevenueEntryCard(entry: entry),
                        const SizedBox(height: 16),
                      ],
                      if (controller.hasMoreEntries)
                        Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: controller.toggleExpanded,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.isExpanded.value
                                      ? 'Show less'
                                      : 'Show more',
                                  style: const TextStyle(
                                    color: PartnerPalette.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  controller.isExpanded.value
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: PartnerPalette.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.footer,
  });

  final String label;
  final String value;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      // The pair of cards sit side by side, so this is a minimum height that
      // keeps them even; either can grow for a longer figure.
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: PartnerPalette.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PartnerStyle.metricLabel,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: PartnerStyle.metricValue),
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}

class _ChangeFooter extends StatelessWidget {
  const _ChangeFooter({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final isUp = percent >= 0;
    final colour = isUp ? PartnerPalette.positive : PartnerPalette.danger;

    return Row(
      children: [
        Icon(
          isUp ? Icons.trending_up : Icons.trending_down,
          size: 14,
          color: colour,
        ),
        const SizedBox(width: 4),
        Text(
          '${percent.abs().toStringAsFixed(1)}%',
          style: PartnerStyle.metricLabel.copyWith(color: colour),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.controller});

  final RevenueController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: PartnerPalette.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: PartnerPalette.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Revenue trend',
                  style: TextStyle(color: Color(0xFF1A1B1F), fontSize: 16),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: PartnerPalette.headerGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF006E28),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: RevenueChart(
              values: controller.chartValues.toList(),
              labels: controller.chartLabels.toList(),
              highlightIndex: controller.chartValues.isEmpty
                  ? null
                  : controller.chartValues.length ~/ 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueEntryCard extends StatelessWidget {
  const _RevenueEntryCard({required this.entry});

  final RevenueEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: PartnerPalette.white,
        border: Border.all(color: PartnerPalette.border),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: PartnerPalette.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.customerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PartnerPalette.heading,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.listingName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PartnerPalette.subtleText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                RevenueController.formatRupees(entry.amount),
                style: const TextStyle(
                  color: PartnerPalette.headerGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: PartnerPalette.mutedLabel,
              ),
              const SizedBox(width: 4),
              Text(entry.date, style: PartnerStyle.metricLabel),
            ],
          ),
        ],
      ),
    );
  }
}
