import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_fields.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/partner_onboarding_controller.dart';
import 'onboarding_intro_steps.dart';
import '../../../widgets/maps/app_maps.dart';

/// Step 1a — "Choose your type".
class ActivityTypeStep extends StatelessWidget {
  const ActivityTypeStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  static const _icons = [
    Icons.directions_boat_outlined,
    Icons.hiking_outlined,
    Icons.house_outlined,
    Icons.bed_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Choose your type',
          alignment: CrossAxisAlignment.start,
        ),
        Obx(
          () => Column(
            children: [
              // The first two types are full-width; "Stay" splits into a pair.
              for (var index = 0; index < 2; index++) ...[
                PartnerOptionCard(
                  label: PartnerOnboardingController.activityTypes[index],
                  icon: _icons[index],
                  selected: controller.selectedActivityType.value == index,
                  onTap: () => controller.selectActivityType(index),
                ),
                const SizedBox(height: 20),
              ],
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Stay',
                  style: TextStyle(
                    color: PartnerPalette.headingDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var index = 2; index < 4; index++) ...[
                    Expanded(
                      child: PartnerOptionCard(
                        label:
                            PartnerOnboardingController.activityTypes[index],
                        icon: _icons[index],
                        axis: Axis.vertical,
                        selected:
                            controller.selectedActivityType.value == index,
                        onTap: () => controller.selectActivityType(index),
                      ),
                    ),
                    if (index == 2) const SizedBox(width: 20),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step 1b — "Search your location".
class LocationStep extends StatelessWidget {
  const LocationStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Search your location',
          alignment: CrossAxisAlignment.start,
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: PartnerPalette.white,
            border: Border.all(color: PartnerPalette.hairline),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: PartnerPalette.black.withValues(alpha: 0.2),
                blurRadius: 13,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 20,
                color: PartnerPalette.black,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.locationQuery,
                  onChanged: controller.onLocationQueryChanged,
                  style: PartnerStyle.fieldValue,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Enter your location',
                    hintStyle: PartnerStyle.fieldValue,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Column(
            children: [
              for (final suggestion in controller.suggestions)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(suggestion.primaryText),
                  subtitle: suggestion.secondaryText.isEmpty
                      ? null
                      : Text(suggestion.secondaryText),
                  onTap: () => controller.selectSuggestion(suggestion),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.useCurrentLocation,
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                controller.isLocating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.my_location,
                        size: 16,
                        color: PartnerPalette.black,
                      ),
                const SizedBox(width: 8),
                const Text(
                  'Choose current location',
                  style: TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => controller.locationError.value.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    controller.locationError.value,
                    style: const TextStyle(color: PartnerPalette.danger),
                  ),
                ),
        ),
        const SizedBox(height: 30),
        Obx(
          () => PinPickerMap(
            point: controller.pinnedPoint.value,
            onPinMoved: controller.onPinMoved,
          ),
        ),
      ],
    );
  }
}

/// Step 1c — "Confirm your address".
class AddressStep extends StatelessWidget {
  const AddressStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Confirm your address',
          alignment: CrossAxisAlignment.start,
        ),
        PartnerTextField(
          hint: 'Flat, house',
          controller: controller.addressLine1,
          onChanged: (_) => controller.step.refresh(),
        ),
        const SizedBox(height: 8),
        PartnerTextField(
          hint: 'Street, locality',
          controller: controller.addressLine2,
        ),
        const SizedBox(height: 8),
        PartnerTextField(hint: 'City', controller: controller.city),
        const SizedBox(height: 8),
        PartnerTextField(hint: 'State', controller: controller.state),
        const SizedBox(height: 8),
        PartnerTextField(
          hint: 'Pin code',
          controller: controller.pincode,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            const Expanded(
              child: Text(
                "Show your home's precise location",
                style: TextStyle(
                  color: PartnerPalette.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Obx(
              () => Switch(
                value: controller.showPreciseLocation.value,
                activeThumbColor: PartnerPalette.white,
                activeTrackColor: PartnerPalette.headerGreen,
                onChanged: (value) =>
                    controller.showPreciseLocation.value = value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Drag to fine-tune the pin; the typed address stays as confirmed.
        Obx(
          () => PinPickerMap(
            point: controller.pinnedPoint.value,
            onPinMoved: controller.onPinMoved,
            height: 260,
          ),
        ),
      ],
    );
  }
}

/// Step 1d — "Fill your plan details": capacity counters.
class PlanDetailsStep extends StatelessWidget {
  const PlanDetailsStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Fill your plan details',
          subtitle: 'Your can change this at anytime',
          alignment: CrossAxisAlignment.start,
        ),
        Obx(
          () => Column(
            children: [
              PartnerCounterRow(
                label: 'Guests',
                value: controller.guests.value,
                onDecrement: () => controller.adjustGuests(-1),
                onIncrement: () => controller.adjustGuests(1),
              ),
              const _RowDivider(),
              PartnerCounterRow(
                label: 'Bedrooms',
                value: controller.bedrooms.value,
                onDecrement: () => controller.adjustBedrooms(-1),
                onIncrement: () => controller.adjustBedrooms(1),
              ),
              const _RowDivider(),
              PartnerCounterRow(
                label: 'Beds',
                value: controller.beds.value,
                onDecrement: () => controller.adjustBeds(-1),
                onIncrement: () => controller.adjustBeds(1),
              ),
              const _RowDivider(),
              PartnerCounterRow(
                label: 'Bathrooms',
                value: controller.bathrooms.value,
                onDecrement: () => controller.adjustBathrooms(-1),
                onIncrement: () => controller.adjustBathrooms(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step 1e — daily slots: how many, and the window each one covers.
class SlotsStep extends StatelessWidget {
  const SlotsStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Fill your plan details',
          subtitle: 'Your can change this at anytime',
          alignment: CrossAxisAlignment.start,
        ),
        Obx(
          () => Column(
            children: [
              PartnerValueRow(
                title: 'Slot number',
                caption: 'Number of slots in a day',
                value: '${controller.slots.length}',
                onTap: controller.addSlot,
              ),
              const _RowDivider(),
              for (var index = 0; index < controller.slots.length; index++) ...[
                _SlotCard(
                  controller: controller,
                  index: index,
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.controller, required this.index});

  final PartnerOnboardingController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final slot = controller.slots[index];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: PartnerDecoration.field(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Slot ${index + 1}',
                  style: const TextStyle(
                    color: PartnerPalette.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.removeSlot(index),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: PartnerPalette.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Start time',
                  value: slot.start,
                  onPick: (value) =>
                      controller.updateSlot(index, start: value),
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: _TimeField(
                  label: 'End time',
                  value: slot.end,
                  onPick: (value) => controller.updateSlot(index, end: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final String value;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: PartnerPalette.black, fontSize: 14),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null && context.mounted) {
              onPick(picked.format(context));
            }
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(color: PartnerPalette.border),
              borderRadius: BorderRadius.circular(68),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: PartnerPalette.black,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Divider(color: PartnerPalette.hairline, height: 1),
    );
  }
}
