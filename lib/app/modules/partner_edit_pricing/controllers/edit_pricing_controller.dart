import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';

/// Partner-side Page 3.3 — Edit Price and Discount.
///
/// Base price and the discounted price are two views of the same number, so
/// editing either one keeps the percentage in step. Saving writes the base
/// price and discount percentage to the listing.
class EditPricingController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();

  /// The backend's ceiling (PartnerPortalRules.MaxDiscountPercent).
  static const maxDiscountPercent = 90.0;

  final listingName = 'Listing'.obs;
  String _listingId = '';

  final basePrice = 0.0.obs;
  final discountedPrice = TextEditingController(text: '0');
  final discountPercent = TextEditingController(text: '0');

  final isSaving = false.obs;

  /// Guards against the two fields updating each other in a loop.
  bool _syncing = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      _listingId = '${args['listingId'] ?? ''}';
      final name = args['listingName'];
      if (name is String && name.trim().isNotEmpty) {
        listingName.value = name.trim();
      }
      final price = args['basePrice'];
      if (price is num) {
        basePrice.value = price.toDouble();
      }
      final percent = args['discountPercent'];
      discountPercent.text =
          (percent is num ? percent.toDouble() : 0).toStringAsFixed(0);
    }
    onDiscountPercentChanged(discountPercent.text);
  }

  @override
  void onClose() {
    discountedPrice.dispose();
    discountPercent.dispose();
    super.onClose();
  }

  /// Recomputes the percentage from a newly typed final price.
  void onDiscountedPriceChanged(String value) {
    if (_syncing) {
      return;
    }
    final price = double.tryParse(value);
    final base = basePrice.value;
    if (price == null || base <= 0) {
      return;
    }
    _syncing = true;
    final percent = ((base - price) / base * 100).clamp(0, 100);
    discountPercent.text = percent.toStringAsFixed(0);
    _syncing = false;
  }

  /// Recomputes the final price from a newly typed percentage.
  void onDiscountPercentChanged(String value) {
    if (_syncing) {
      return;
    }
    final percent = double.tryParse(value);
    if (percent == null) {
      return;
    }
    _syncing = true;
    final price = basePrice.value * (1 - percent.clamp(0, 100) / 100);
    discountedPrice.text = price.toStringAsFixed(0);
    _syncing = false;
  }

  /// Asks for a new base price; it's saved together with the discount.
  Future<void> changeBasePrice() async {
    final field = TextEditingController(text: basePrice.value.toStringAsFixed(0));
    final value = await Get.dialog<double>(
      AlertDialog(
        title: const Text('Base price'),
        content: TextField(
          controller: field,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: double.tryParse(field.text)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    field.dispose();

    if (value != null && value > 0) {
      basePrice.value = value;
      onDiscountPercentChanged(discountPercent.text);
    }
  }

  Future<void> save() async {
    final percent = double.tryParse(discountPercent.text) ?? -1;
    if (percent < 0 || percent > maxDiscountPercent) {
      _snack('Discount must be between 0 and ${maxDiscountPercent.toStringAsFixed(0)}%.');
      return;
    }
    if (basePrice.value <= 0) {
      _snack('Set a base price first.');
      return;
    }

    isSaving.value = true;
    try {
      await _partnerService.updateListing(_listingId, {
        'basePrice': basePrice.value,
        'discountPercent': percent,
      });
      Get.back(result: true);
    } on ApiException catch (error) {
      _snack(error.message);
    } finally {
      isSaving.value = false;
    }
  }

  void _snack(String message) => Get.snackbar(
        'Pricing',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );

  void goBack() => Get.back();
}
