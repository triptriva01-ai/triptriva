import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_booking_card.dart';
import '../../../widgets/partner/partner_page_header.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/confirm_customer_controller.dart';

/// Partner-side Page 2.2 — Confirm the customer, and the success state that
/// replaces it once the booking ID checks out.
class ConfirmCustomerView extends GetView<ConfirmCustomerController> {
  const ConfirmCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartnerPalette.white,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => controller.isConfirmed.value
              ? _SuccessState(controller: controller)
              : _EntryState(controller: controller),
        ),
      ),
    );
  }
}

class _EntryState extends StatelessWidget {
  const _EntryState({required this.controller});

  final ConfirmCustomerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        PartnerPageHeader(
          title: 'Confirm the customer',
          onBack: controller.goBack,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              PartnerSizes.pagePadding,
              30,
              PartnerSizes.pagePadding,
              24,
            ),
            child: Column(
              children: [
                _CustomerCard(controller: controller),
                const SizedBox(height: 60),
                const Text(
                  'Enter the booking ID',
                  style: TextStyle(
                    color: PartnerPalette.inactiveTab,
                    fontSize: 20,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 30),
                _CodeBoxes(controller: controller),
                Obx(
                  () => controller.errorMessage.value.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: PartnerPalette.danger,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PartnerSizes.pagePadding,
              0,
              PartnerSizes.pagePadding,
              20,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Obx(
                () => PartnerPrimaryButton(
                  label: 'Confirm',
                  expand: true,
                  onPressed:
                      controller.isComplete && !controller.isVerifying.value
                          ? controller.confirm
                          : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Guest summary above the code entry: photo, name and the slot they booked.
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.controller});

  final ConfirmCustomerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.22],
          colors: [Color(0xB3FFFFFF), PartnerPalette.white],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: PartnerPalette.black.withValues(alpha: 0.1),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: PartnerPalette.white, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: PartnerPalette.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: PartnerAvatar(
                imageUrl: controller.avatarUrl.value,
                size: 100,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Text(
                    controller.customerName.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PartnerPalette.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text('Entry time', style: PartnerStyle.cardMeta),
                const SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 19,
                    runSpacing: 4,
                    children: [
                      if (controller.entryDate.value.isNotEmpty)
                        Text(
                          controller.entryDate.value,
                          style: PartnerStyle.cardMeta,
                        ),
                      Text(
                        controller.entryTime.value.toUpperCase(),
                        style: PartnerStyle.cardMeta,
                      ),
                    ],
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

/// Six circles that mirror a single hidden field, so the platform keyboard and
/// paste behaviour keep working.
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.controller});

  final ConfirmCustomerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0;
                  index < ConfirmCustomerController.codeLength;
                  index++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PartnerPalette.white,
                      border: Border.all(color: PartnerPalette.bodyDark),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      index < controller.code.value.length
                          ? controller.code.value[index]
                          : '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PartnerPalette.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Invisible but focusable, sized to cover the boxes so a tap anywhere
        // on the row opens the keyboard.
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: ConfirmCustomerController.codeLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: controller.onCodeChanged,
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.controller});

  final ConfirmCustomerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        PartnerPageHeader(
          title: 'Confirm the customer',
          onBack: controller.done,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 208,
                  height: 208,
                  decoration: const BoxDecoration(
                    color: PartnerPalette.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        gradient: PartnerGradients.prime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 78,
                        color: PartnerPalette.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: PartnerGradients.prime.createShader,
                  child: const Text(
                    'SUCCESS',
                    style: TextStyle(
                      color: PartnerPalette.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Your user is ready for the adventure',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 20,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PartnerSizes.pagePadding,
              0,
              PartnerSizes.pagePadding,
              20,
            ),
            child: SizedBox(
              width: double.infinity,
              child: PartnerPrimaryButton(
                label: 'Done',
                expand: true,
                onPressed: controller.done,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
