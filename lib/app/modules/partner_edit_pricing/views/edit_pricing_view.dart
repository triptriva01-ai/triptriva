import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_page_header.dart';
import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../controllers/edit_pricing_controller.dart';

/// Partner-side Page 3.3 — Edit Price and Discount.
class EditPricingView extends GetView<EditPricingController> {
  const EditPricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0D0D0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Obx(
              () => PartnerPageHeader(
                title: controller.listingName.value,
                onBack: controller.goBack,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: PartnerDecoration.sheet,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    PartnerSizes.pagePadding,
                    30,
                    PartnerSizes.pagePadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Base Price', style: PartnerStyle.cardTitle),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(minHeight: 67),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: PartnerPalette.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: PartnerPalette.hairline),
                        ),
                        child: Row(
                          children: [
                            Obx(
                              () => Text(
                                '₹${controller.basePrice.value.toStringAsFixed(0)}/-',
                                style: PartnerStyle.fieldValue,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: controller.changeBasePrice,
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  color: PartnerPalette.link,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: PartnerPalette.hairline, height: 1),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _PriceField(
                              label: 'Discounted Price',
                              prefix: '₹',
                              controller: controller.discountedPrice,
                              onChanged: controller.onDiscountedPriceChanged,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _PriceField(
                              label: 'In Percent',
                              suffix: '%',
                              controller: controller.discountPercent,
                              onChanged: controller.onDiscountPercentChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: PartnerPalette.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PartnerSizes.pagePadding,
                    10,
                    PartnerSizes.pagePadding,
                    20,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => PartnerPrimaryButton(
                        label: 'Save',
                        expand: true,
                        onPressed:
                            controller.isSaving.value ? null : controller.save,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.prefix,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PartnerStyle.cardTitle),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 63),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: PartnerPalette.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: PartnerPalette.hairline),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            style: PartnerStyle.fieldValue,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              prefixText: prefix,
              suffixText: suffix,
              prefixStyle: PartnerStyle.fieldValue,
              suffixStyle: PartnerStyle.fieldValue,
            ),
          ),
        ),
      ],
    );
  }
}
