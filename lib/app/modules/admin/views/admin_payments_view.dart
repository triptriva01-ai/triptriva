import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/admin_constants.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_shell.dart';
import '../widgets/payment_card.dart';

/// Admin — payment release.
class AdminPaymentsView extends GetView<AdminPaymentsController> {
  const AdminPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdminShell(
        title: AdminStrings.paymentRelease,
        currentIndex: controller.currentTab.value,
        onTabSelected: controller.onTabSelected,
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
              Obx(
                () => AdminFilterChips(
                  labels: const [
                    AdminStrings.sortByUser,
                    AdminStrings.sortByDate,
                  ],
                  selectedIndex: controller.sortByDate.value ? 1 : 0,
                  onSelected: (index) => index == 0
                      ? controller.sortByUser()
                      : controller.sortByDateSelected(),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final payments = controller.payments.toList();
                if (payments.isEmpty) {
                  return const Text(
                    AdminStrings.empty,
                    style: AdminStyle.cardMeta,
                  );
                }

                final expandedId = controller.expandedId.value;
                return Column(
                  children: [
                    for (final payment in payments) ...[
                      PaymentCard(
                        payment: payment,
                        isExpanded: payment.id == expandedId,
                        onToggle: () => controller.toggleExpanded(payment),
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
}
