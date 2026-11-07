import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/partner/partner_fields.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/partner_onboarding_controller.dart';
import 'onboarding_intro_steps.dart';

/// Step 2a — "Give a name".
class ListingNameStep extends StatelessWidget {
  const ListingNameStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Give a name',
          alignment: CrossAxisAlignment.start,
        ),
        PartnerTextField(
          hint: 'Flat , house',
          controller: controller.listingTitle,
          maxLength: PartnerOnboardingController.titleMaxLength,
          onChanged: (_) => controller.step.refresh(),
        ),
        const SizedBox(height: 8),
        Obx(() {
          // Reading `step` keeps this counter live as the title is typed.
          controller.step.value;
          final remaining = PartnerOnboardingController.titleMaxLength -
              controller.listingTitle.text.length;
          return Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$remaining characters left',
              style: const TextStyle(
                color: PartnerPalette.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Step 2b — "Give more details": description plus the house rules shown to
/// guests as chips.
class ListingDetailsStep extends StatelessWidget {
  const ListingDetailsStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Give more details',
          alignment: CrossAxisAlignment.start,
        ),
        PartnerTextField(
          hint: 'Describe your place',
          controller: controller.listingDescription,
          maxLines: 6,
        ),
        const SizedBox(height: 30),
        const Text(
          'Instructions to the guest',
          style: PartnerStyle.formHeading,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: PartnerDecoration.field(),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.instructionDraft,
                  onSubmitted: (_) => controller.addInstruction(),
                  style: PartnerStyle.fieldValue,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'e.g. No pets',
                    hintStyle: PartnerStyle.fieldLabel,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.addInstruction,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: PartnerGradients.prime,
                    shape: BoxShape.circle,
                  ),
                  foregroundDecoration: BoxDecoration(
                    color: PartnerPalette.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 20,
                    color: PartnerPalette.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              // `.toList()` makes the observable read explicit rather than
              // relying on RxList's iterator reporting it.
              for (final instruction in controller.instructions.toList())
                _InstructionChip(
                  label: instruction,
                  onRemove: () => controller.removeInstruction(instruction),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionChip extends StatelessWidget {
  const _InstructionChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: PartnerPalette.black,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: PartnerPalette.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 12,
              color: PartnerPalette.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 2c — "Facilities you provide".
class FacilitiesStep extends StatelessWidget {
  const FacilitiesStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  static const _icons = {
    'Wifi': Icons.wifi,
    'TV': Icons.tv,
    'Parking space': Icons.local_parking,
    'Gym': Icons.fitness_center,
    'Air condition': Icons.ac_unit,
    'Breakfast': Icons.free_breakfast,
    'Meal': Icons.restaurant,
    'Dinner': Icons.dinner_dining,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Facilities you provide',
          alignment: CrossAxisAlignment.start,
        ),
        const Text('Set essential', style: PartnerStyle.formHeading),
        const SizedBox(height: 12),
        _FacilityGrid(
          controller: controller,
          facilities: PartnerOnboardingController.essentialFacilities,
        ),
        const SizedBox(height: 30),
        const Text('Food', style: PartnerStyle.formHeading),
        const SizedBox(height: 12),
        _FacilityGrid(
          controller: controller,
          facilities: PartnerOnboardingController.foodFacilities,
        ),
      ],
    );
  }
}

class _FacilityGrid extends StatelessWidget {
  const _FacilityGrid({required this.controller, required this.facilities});

  final PartnerOnboardingController controller;
  final List<String> facilities;

  static const _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    // A Wrap rather than a GridView: GridView's mainAxisExtent is an exact
    // height, so a longer label or a larger system font would be clipped.
    // Wrap lets each row take the height its tallest card needs.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - _spacing) / 2;
        return Obx(
          () => Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: [
              for (final facility in facilities)
                SizedBox(
                  width: columnWidth,
                  child: PartnerOptionCard(
                    label: facility,
                    icon: FacilitiesStep._icons[facility] ??
                        Icons.check_circle_outline,
                    axis: Axis.vertical,
                    height: 100,
                    selected: controller.selectedFacilities.contains(facility),
                    onTap: () => controller.toggleFacility(facility),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Step 2d — "Add images of your property".
class PhotosStep extends StatelessWidget {
  const PhotosStep({required this.controller, super.key});

  final PartnerOnboardingController controller;

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final files = await picker.pickMultiImage();
      for (final file in files) {
        controller.addPhoto(file.path);
      }
      return;
    }
    final file = await picker.pickImage(source: source);
    if (file != null) {
      controller.addPhoto(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingStepHeading(
          title: 'Add images of your property',
          subtitle: 'Need atleast '
              '${PartnerOnboardingController.minimumPhotos} photos of your property',
        ),
        Obx(
          () => Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              // `.toList()` makes the observable read explicit rather than
              // relying on RxList's iterator reporting it.
              for (final path in controller.photoPaths.toList())
                _PhotoTile(
                  path: path,
                  onRemove: () => controller.removePhoto(path),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text('Want to add more images', style: PartnerStyle.formHeading),
        const SizedBox(height: 12),
        Row(
          children: [
            _PickerButton(
              icon: Icons.photo_camera_outlined,
              label: 'Camera',
              onTap: () => _pick(ImageSource.camera),
            ),
            const SizedBox(width: 20),
            _PickerButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: () => _pick(ImageSource.gallery),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => Text(
            '${controller.photoPaths.length} of '
            '${PartnerOnboardingController.minimumPhotos} added',
            style: PartnerStyle.rowCaption,
          ),
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 128,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: PartnerPalette.hairline,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: PartnerPalette.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: PartnerPalette.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: PartnerDecoration.field(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: PartnerPalette.black),
              const SizedBox(width: 20),
              Text(
                label,
                style: const TextStyle(
                  color: PartnerPalette.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
