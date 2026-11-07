import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/services/profile_service.dart';
import '../constants/account_settings_constants.dart';

void _showError(Object error) {
  Get.snackbar(
    AccountSettingsStrings.errorTitle,
    error is ApiException ? error.message : '$error',
    snackPosition: SnackPosition.BOTTOM,
  );
}

void _showInfo(String title, [String message = '']) {
  Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
}

String? _platformName() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  return null;
}

// ─────────────────────────────── Feedback ───────────────────────────────

/// Free-text feedback, stored by `POST /api/users/feedback` for admin review.
class FeedbackController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final message = TextEditingController();
  final length = 0.obs;
  final isSending = false.obs;

  bool get canSubmit =>
      length.value >= AccountSettingsStrings.minMessageLength &&
      !isSending.value;

  @override
  void onInit() {
    super.onInit();
    message.addListener(() => length.value = message.text.trim().length);
  }

  @override
  void onClose() {
    message.dispose();
    super.onClose();
  }

  void reset() => message.clear();

  Future<void> submit() async {
    if (length.value < AccountSettingsStrings.minMessageLength) {
      _showInfo(AccountSettingsStrings.feedbackTooShort);
      return;
    }
    isSending.value = true;
    try {
      await _profileService.submitFeedback(
        message.text.trim(),
        platform: _platformName(),
      );
      message.clear();
      Get.back();
      _showInfo(AccountSettingsStrings.feedbackThanks);
    } catch (error) {
      _showError(error);
    } finally {
      isSending.value = false;
    }
  }

  void goBack() => Get.back();
}

// ─────────────────────────────── Language ───────────────────────────────

/// The account's preferred language (`GET`/`PUT /api/users/language`).
class LanguageController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final selected = AccountSettingsConfig.defaultLanguageCode.obs;
  final isLoading = false.obs;
  final savingCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final data = await _profileService.getLanguage();
      final code = data is Map ? data['languageCode'] : null;
      if (code is String && code.isNotEmpty) {
        selected.value = code;
      }
    } catch (error) {
      Get.log('Language load failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> choose(String code) async {
    if (code == selected.value || savingCode.value.isNotEmpty) {
      return;
    }
    final previous = selected.value;
    selected.value = code;
    savingCode.value = code;
    try {
      await _profileService.setLanguage(code);
      _showInfo(AccountSettingsStrings.languageSaved);
    } catch (error) {
      selected.value = previous;
      _showError(error);
    } finally {
      savingCode.value = '';
    }
  }

  void goBack() => Get.back();
}

// ─────────────────────────── Customer support ───────────────────────────

/// "Enter your problem" plus the support phone lines.
class CustomerSupportController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final problem = TextEditingController();
  final length = 0.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    problem.addListener(() => length.value = problem.text.trim().length);
  }

  @override
  void onClose() {
    problem.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (length.value < AccountSettingsStrings.minMessageLength) {
      _showInfo(AccountSettingsStrings.feedbackTooShort);
      return;
    }
    isSending.value = true;
    try {
      await _profileService.submitFeedback(
        problem.text.trim(),
        category: 'support',
        platform: _platformName(),
      );
      problem.clear();
      _showInfo(AccountSettingsStrings.supportTitle,
          AccountSettingsStrings.supportSent);
    } catch (error) {
      _showError(error);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> call(SupportLine line) async {
    if (line.phone.isEmpty) {
      _showInfo(line.label, AccountSettingsStrings.supportLineUnavailable);
      return;
    }
    final launched = await launchUrl(Uri(scheme: 'tel', path: line.phone));
    if (!launched) {
      _showInfo(line.label, AccountSettingsStrings.callFailed);
    }
  }

  void goBack() => Get.back();
}

// ─────────────────────────── Payment methods ───────────────────────────

/// A saved payment method as `GET /api/users/payment-methods` returns it.
class SavedPaymentMethod {
  const SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    this.isDefault = false,
    this.isExpired = false,
    this.walletProvider,
    this.cardHolderName,
    this.cardExpiryMonth,
    this.cardExpiryYear,
  });

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) => value is num ? value.toInt() : null;
    return SavedPaymentMethod(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? ''}',
      displayName: '${json['displayName'] ?? ''}',
      isDefault: json['isDefault'] == true,
      isExpired: json['isExpired'] == true,
      walletProvider: json['walletProvider'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      cardExpiryMonth: toInt(json['cardExpiryMonth']),
      cardExpiryYear: toInt(json['cardExpiryYear']),
    );
  }

  final String id;
  final String type;
  final String displayName;
  final bool isDefault;
  final bool isExpired;
  final String? walletProvider;
  final String? cardHolderName;
  final int? cardExpiryMonth;
  final int? cardExpiryYear;

  bool get isCard => type == 'card';
  bool get isUpi => type == 'upi';
  bool get isWallet => type == 'wallet';

  String get expiryLabel => cardExpiryMonth == null || cardExpiryYear == null
      ? ''
      : '${cardExpiryMonth.toString().padLeft(2, '0')} / '
          '${(cardExpiryYear! % 100).toString().padLeft(2, '0')}';
}

/// The UPI apps offered as one-tap choices.
class UpiApp {
  const UpiApp(this.provider, this.label);

  /// `walletProvider` as stored by the backend.
  final String provider;
  final String label;
}

class PaymentMethodsController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  static const upiApps = [
    UpiApp('google_pay', AccountSettingsStrings.googlePay),
    UpiApp('phonepe', AccountSettingsStrings.phonePe),
    UpiApp('paytm', AccountSettingsStrings.paytm),
  ];

  final methods = <SavedPaymentMethod>[].obs;
  final isLoading = false.obs;
  final busyId = ''.obs;

  final upiExpanded = true.obs;
  final cardExpanded = false.obs;

  /// The id of the card being edited, or empty while adding a new one.
  final editingCardId = ''.obs;
  final cardFormOpen = false.obs;
  final isSavingCard = false.obs;
  final cardError = ''.obs;

  final cardName = TextEditingController();
  final cardNumber = TextEditingController();
  final cardExpiry = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    cardName.dispose();
    cardNumber.dispose();
    cardExpiry.dispose();
    super.onClose();
  }

  List<SavedPaymentMethod> get cards =>
      methods.where((method) => method.isCard).toList();

  List<SavedPaymentMethod> get upiIds =>
      methods.where((method) => method.isUpi).toList();

  SavedPaymentMethod? walletFor(String provider) =>
      methods.firstWhereOrNull(
        (method) => method.isWallet && method.walletProvider == provider,
      );

  Future<void> load() async {
    isLoading.value = true;
    try {
      final data = await _profileService.getPaymentMethods();
      final list = data is List ? data : const [];
      methods.assignAll(
        list.whereType<Map<String, dynamic>>().map(SavedPaymentMethod.fromJson),
      );
    } catch (error) {
      _showError(error);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleUpi() => upiExpanded.toggle();

  void toggleCards() {
    cardExpanded.toggle();
    if (!cardExpanded.value) closeCardForm();
  }

  /// Picks a UPI app as the default way to pay, saving it on first use.
  Future<void> chooseUpiApp(UpiApp app) async {
    final existing = walletFor(app.provider);
    if (existing?.isDefault == true) return;
    await _mutate(existing?.id ?? app.provider, () async {
      if (existing == null) {
        await _profileService.addPaymentMethod({
          'type': 'wallet',
          'walletProvider': app.provider,
          'isDefault': true,
        });
      } else {
        await _profileService.updatePaymentMethod(
          existing.id,
          {'isDefault': true},
        );
      }
    });
  }

  Future<void> makeDefault(SavedPaymentMethod method) async {
    if (method.isDefault) return;
    await _mutate(
      method.id,
      () => _profileService.updatePaymentMethod(method.id, {'isDefault': true}),
    );
  }

  Future<void> addUpiId(String upiId) async {
    final value = upiId.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9._-]{2,256}@[a-z][a-z0-9.-]{1,63}$').hasMatch(value)) {
      _showInfo(AccountSettingsStrings.invalidUpi);
      return;
    }
    Get.back();
    await _mutate('upi', () async {
      await _profileService.addPaymentMethod({'type': 'upi', 'upiId': value});
    });
  }

  Future<void> remove(SavedPaymentMethod method) async {
    await _mutate(
      method.id,
      () => _profileService.removePaymentMethod(method.id),
    );
  }

  // ── Card form ──

  void openNewCard() {
    editingCardId.value = '';
    cardName.clear();
    cardNumber.clear();
    cardExpiry.clear();
    cardError.value = '';
    cardExpanded.value = true;
    cardFormOpen.value = true;
  }

  /// Only the holder name and expiry of a saved card can change.
  void openEditCard(SavedPaymentMethod card) {
    editingCardId.value = card.id;
    cardName.text = card.cardHolderName ?? '';
    cardNumber.text = card.displayName;
    cardExpiry.text = card.expiryLabel.replaceAll(' ', '');
    cardError.value = '';
    cardExpanded.value = true;
    cardFormOpen.value = true;
  }

  void closeCardForm() {
    cardFormOpen.value = false;
    editingCardId.value = '';
    cardError.value = '';
  }

  Future<void> saveCard() async {
    final isEditing = editingCardId.value.isNotEmpty;
    final name = cardName.text.trim();
    final expiry = _parseExpiry(cardExpiry.text);
    final digits = cardNumber.text.replaceAll(RegExp(r'\D'), '');

    if (name.isEmpty) {
      cardError.value = AccountSettingsStrings.nameRequired;
      return;
    }
    if (!isEditing && !_isValidCardNumber(digits)) {
      cardError.value = AccountSettingsStrings.invalidCardNumber;
      return;
    }
    if (expiry == null) {
      cardError.value = AccountSettingsStrings.invalidExpiry;
      return;
    }
    cardError.value = '';
    isSavingCard.value = true;
    try {
      if (isEditing) {
        await _profileService.updatePaymentMethod(editingCardId.value, {
          'cardHolderName': name,
          'cardExpiryMonth': expiry.$1,
          'cardExpiryYear': expiry.$2,
        });
      } else {
        // The full number is used only to derive the brand and last four
        // digits; it is never sent to the server.
        await _profileService.addPaymentMethod({
          'type': 'card',
          'cardBrand': _brandOf(digits),
          'cardLast4': digits.substring(digits.length - 4),
          'cardExpiryMonth': expiry.$1,
          'cardExpiryYear': expiry.$2,
          'cardHolderName': name,
        });
      }
      closeCardForm();
      await load();
      _showInfo(AccountSettingsStrings.saved);
    } catch (error) {
      cardError.value =
          error is ApiException ? error.message : '$error';
    } finally {
      isSavingCard.value = false;
    }
  }

  Future<void> _mutate(String id, Future<void> Function() action) async {
    busyId.value = id;
    try {
      await action();
      await load();
    } catch (error) {
      _showError(error);
    } finally {
      busyId.value = '';
    }
  }

  /// "07/29" or "0729" → (7, 2029); null when malformed.
  static (int, int)? _parseExpiry(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 4) return null;
    final month = int.parse(digits.substring(0, 2));
    final year = 2000 + int.parse(digits.substring(2));
    if (month < 1 || month > 12) return null;
    return (month, year);
  }

  static bool _isValidCardNumber(String digits) {
    if (digits.length < 12 || digits.length > 19) return false;
    var sum = 0;
    var doubleIt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var value = int.parse(digits[i]);
      if (doubleIt) {
        value *= 2;
        if (value > 9) value -= 9;
      }
      sum += value;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }

  static String _brandOf(String digits) {
    if (digits.startsWith('4')) return 'visa';
    if (RegExp(r'^(34|37)').hasMatch(digits)) return 'amex';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) return 'mastercard';
    if (RegExp(r'^(60|65|81|82|508)').hasMatch(digits)) return 'rupay';
    return 'card';
  }

  void goBack() => Get.back();
}
