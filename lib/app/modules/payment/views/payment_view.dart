import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/payment_constants.dart';
import '../controllers/payment_controller.dart';

/// Payment page — gradient header with the total, then the methods and
/// the bill on a white sheet.
class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: PaymentPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PaymentPalette.white,
        body: Stack(
          children: [
            Container(
              height: PaymentSizes.headerHeight + top,
              decoration: const BoxDecoration(gradient: PaymentGradients.header),
            ),
            Column(
              children: [
                SizedBox(
                  height: PaymentSizes.headerHeight + top -
                      PaymentSizes.sheetOverlap,
                  child: _Header(controller: controller, topInset: top),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: PaymentPalette.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(PaymentSizes.sheetRadius),
                      ),
                    ),
                    child: _Body(controller: controller),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: _PayBar(controller: controller),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.topInset});

  final PaymentController controller;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 8,
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back, color: PaymentPalette.white),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(PaymentStrings.totalAmount, style: PaymentStyle.totalLabel),
                const SizedBox(height: 6),
                Obx(
                  () => FittedBox(
                    child: Text(
                      controller.totalLabel,
                      style: PaymentStyle.totalValue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        PaymentSizes.pagePadding,
        PaymentSizes.sectionGap,
        PaymentSizes.pagePadding,
        PaymentSizes.pagePadding,
      ),
      child: Obx(() {
        final expanded = controller.expanded.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(PaymentStrings.paymentMethods, style: PaymentStyle.section),
            const SizedBox(height: PaymentSizes.titleToBody),
            _MethodCard(
              icon: Icons.account_balance_wallet_outlined,
              title: PaymentStrings.upi,
              subtitle: PaymentStrings.upiSubtitle,
              isExpanded: expanded == PaymentMethod.upi,
              onTap: () => controller.toggle(PaymentMethod.upi),
              child: const Text(PaymentStrings.upiHint, style: PaymentStyle.methodSubtitle),
            ),
            const SizedBox(height: PaymentSizes.cardGap),
            _MethodCard(
              icon: Icons.credit_card,
              title: PaymentStrings.card,
              subtitle: PaymentStrings.cardSubtitle,
              isExpanded: expanded == PaymentMethod.card,
              onTap: () => controller.toggle(PaymentMethod.card),
              child: const Text(PaymentStrings.cardHint, style: PaymentStyle.methodSubtitle),
            ),
            const SizedBox(height: PaymentSizes.sectionGap),
            const Text(PaymentStrings.billSummary, style: PaymentStyle.section),
            const SizedBox(height: PaymentSizes.titleToBody),
            Obx(() {
              controller.bill.value; // Rebuild when the server bill lands.
              return _BillCard(controller: controller);
            }),
            const SizedBox(height: 48),
            const Center(child: _Logo()),
          ],
        );
      }),
    );
  }
}

/// A collapsible payment method: white when closed, grey with a white
/// inner panel when open.
class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onTap,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isExpanded ? PaymentPalette.expanded : PaymentPalette.white,
        border: Border.all(color: PaymentPalette.border),
        borderRadius: BorderRadius.circular(PaymentSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(PaymentSizes.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(PaymentSizes.cardPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: PaymentSizes.methodIconSize),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: PaymentStyle.methodTitle),
                        const SizedBox(height: 4),
                        Text(subtitle, style: PaymentStyle.methodSubtitle),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: PaymentPalette.muted,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(PaymentSizes.cardPadding),
              decoration: BoxDecoration(
                color: PaymentPalette.white,
                borderRadius: BorderRadius.circular(PaymentSizes.cardRadius),
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    final args = controller.args;
    final rupees = controller.rupees;
    return Container(
      padding: const EdgeInsets.all(PaymentSizes.cardPadding + 4),
      decoration: BoxDecoration(
        color: PaymentPalette.white,
        border: Border.all(color: PaymentPalette.border),
        borderRadius: BorderRadius.circular(PaymentSizes.cardRadius),
      ),
      child: Column(
        children: [
          _BillRow(
            label: PaymentStrings.totalTripFee,
            value: rupees(args.tripFee),
            original: args.originalTripFee == null
                ? null
                : rupees(args.originalTripFee!),
          ),
          _BillRow(
            label: PaymentStrings.platformFee,
            value: rupees(args.platformFee),
            original: args.originalPlatformFee == null
                ? null
                : rupees(args.originalPlatformFee!),
          ),
          _BillRow(
            label: PaymentStrings.gst,
            value: rupees(args.gst),
            original: args.originalGst == null ? null : rupees(args.originalGst!),
          ),
          _BillRow(
            label: PaymentStrings.couponDiscount,
            value: '- ${rupees(args.couponDiscount)}',
          ),
          _BillRow(
            label: PaymentStrings.youHaveSaved,
            value: '- ${rupees(args.savings)}',
            isSaving: true,
          ),
          const Divider(height: 20, color: PaymentPalette.divider),
          Row(
            children: [
              const Expanded(
                child: Text(PaymentStrings.toPay, style: PaymentStyle.billTotal),
              ),
              Text(controller.totalLabel, style: PaymentStyle.billTotal),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.original,
    this.isSaving = false,
  });

  final String label;
  final String value;
  final String? original;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PaymentSizes.billRowGap),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isSaving ? PaymentStyle.billSaving : PaymentStyle.billLabel,
            ),
          ),
          if (original != null) ...[
            Text(original!, style: PaymentStyle.billStruck),
            const SizedBox(width: 8),
          ],
          Text(
            value,
            style: isSaving ? PaymentStyle.billSaving : PaymentStyle.billValue,
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: PaymentStyle.logo,
        children: [
          const TextSpan(text: PaymentStrings.logoLight),
          TextSpan(
            text: PaymentStrings.logoBold,
            style: PaymentStyle.logo.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Shows once a method is chosen and filled in.
class _PayBar extends StatelessWidget {
  const _PayBar({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = controller.canPay;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PaymentSizes.pagePadding,
            8,
            PaymentSizes.pagePadding,
            12,
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: PaymentGradients.prime,
                borderRadius: BorderRadius.circular(PaymentSizes.buttonRadius),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? controller.pay : null,
                  borderRadius: BorderRadius.circular(PaymentSizes.buttonRadius),
                  child: SizedBox(
                    height: PaymentSizes.buttonHeight,
                    child: Center(
                      child: Text(
                        PaymentStrings.pay(controller.totalLabel),
                        style: PaymentStyle.button,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
