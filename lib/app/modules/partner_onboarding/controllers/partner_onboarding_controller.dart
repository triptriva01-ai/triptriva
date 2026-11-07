import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

import '../../../data/models/geo_place.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/geo_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/media_service.dart';
import '../../../data/services/partner_service.dart';

/// Every screen in the "Add Activity" wizard, in the order the partner walks
/// through them. The four headline steps from the design each expand into
/// several screens; [majorStep] maps a screen back to its headline number.
enum OnboardingStep {
  welcome,
  // 1 — Tell us about your place.
  placeIntro,
  activityType,
  location,
  address,
  planDetails,
  slots,
  // 2 — Make it stand out.
  standOutIntro,
  listingName,
  listingDetails,
  facilities,
  photos,
  // 3 — Pricing and booking type.
  pricingIntro,
  basePrice,
  seasonPricing,
  discounts,
  bookingType,
  // 4 — Finish up and publish.
  finishIntro,
  aboutYou,
  proof,
  // Reached from `proof`; not part of the 4-step progress.
  phoneEntry,
  identityType,
  identityCapture,
}

/// How a guest's reservation is accepted.
enum PartnerBookingType { reviewFirst, instant }

/// Partner listing creation — Sheet2 Page 01 and the screens behind
/// "Get started".
class PartnerOnboardingController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();
  final AuthService _authService = Get.find<AuthService>();

  final step = OnboardingStep.welcome.obs;
  final isSubmitting = false.obs;

  // ── Step 1: the place ───────────────────────────────────────────────
  static const activityTypes = [
    'House Boat',
    'Adventure',
    'home stay',
    'Refreshing room',
  ];
  final selectedActivityType = RxnInt();

  final locationQuery = TextEditingController();
  final addressLine1 = TextEditingController();
  final addressLine2 = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();
  final showPreciseLocation = true.obs;

  // ── Map: search, current location and the pin ──
  final pinnedPoint = Rxn<GeoPoint>();
  final suggestions = <PlaceSuggestion>[].obs;
  final isLocating = false.obs;
  final locationError = ''.obs;
  String _placesSession = GeoService.newSessionToken();
  Timer? _searchDebounce;

  void onLocationQueryChanged(String text) {
    step.refresh();
    _searchDebounce?.cancel();
    if (text.trim().length < 2) {
      suggestions.clear();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        suggestions.assignAll(await Get.find<GeoService>().autocomplete(
          text.trim(),
          sessionToken: _placesSession,
          near: pinnedPoint.value,
        ));
        locationError.value = '';
      } on ApiException catch (error) {
        suggestions.clear();
        locationError.value = error.statusCode == 503
            ? 'Search is unavailable — type your address and continue.'
            : error.message;
      }
    });
  }

  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    suggestions.clear();
    try {
      final place = await Get.find<GeoService>()
          .place(suggestion.placeId, sessionToken: _placesSession);
      _applyPlace(place);
    } on ApiException catch (error) {
      locationError.value = error.message;
    } finally {
      _placesSession = GeoService.newSessionToken();
    }
  }

  Future<void> useCurrentLocation() async {
    isLocating.value = true;
    locationError.value = '';
    try {
      final point = await Get.find<GeoService>().currentLocation();
      pinnedPoint.value = point;
      await _fillFromPoint(point);
    } on LocationUnavailable catch (error) {
      locationError.value = error.message;
    } catch (error) {
      locationError.value = 'Could not get your location.';
    } finally {
      isLocating.value = false;
    }
  }

  /// The user dragged the map. On the search step the address follows the
  /// pin; on the confirm step only the point moves.
  Future<void> onPinMoved(GeoPoint point) async {
    pinnedPoint.value = point;
    if (step.value == OnboardingStep.location) await _fillFromPoint(point);
  }

  Future<void> _fillFromPoint(GeoPoint point) async {
    try {
      final place = await Get.find<GeoService>().reverse(point);
      _applyPlace(place, keepPoint: point);
    } on ApiException {
      if (locationQuery.text.trim().isEmpty) {
        locationQuery.text = point.label;
      }
      step.refresh();
    }
  }

  void _applyPlace(ResolvedPlace place, {GeoPoint? keepPoint}) {
    pinnedPoint.value = keepPoint ?? place.point;
    locationQuery.text = place.formattedAddress;
    if (place.addressLine.isNotEmpty) addressLine1.text = place.addressLine;
    if (place.locality.isNotEmpty) addressLine2.text = place.locality;
    if (place.city.isNotEmpty) city.text = place.city;
    if (place.state.isNotEmpty) state.text = place.state;
    if (place.pincode.isNotEmpty) pincode.text = place.pincode;
    step.refresh();
  }

  /// With "precise location" off, guests see a point rounded to ~1 km.
  Map<String, double> get _coordinates {
    final point = pinnedPoint.value;
    if (point == null) return const {};
    final digits = showPreciseLocation.value ? 6 : 2;
    double round(double v) => double.parse(v.toStringAsFixed(digits));
    return {
      'latitude': round(point.latitude),
      'longitude': round(point.longitude),
    };
  }

  final guests = 1.obs;
  final bedrooms = 1.obs;
  final beds = 1.obs;
  final bathrooms = 1.obs;

  /// Bookable windows within a day; each is a start/end pair.
  final slots = <({String start, String end})>[
    (start: '00 : 00 AM', end: '00 : 00 AM'),
  ].obs;

  // ── Step 2: making it stand out ─────────────────────────────────────
  static const essentialFacilities = ['Wifi', 'TV', 'Parking space', 'Gym', 'Air condition'];
  static const foodFacilities = ['Breakfast', 'Meal', 'Dinner'];
  final selectedFacilities = <String>{}.obs;

  /// Local file paths for now; uploaded on submit.
  final photoPaths = <String>[].obs;
  static const minimumPhotos = 5;

  final listingTitle = TextEditingController();
  final listingDescription = TextEditingController();
  final instructions = <String>[].obs;
  final instructionDraft = TextEditingController();

  static const titleMaxLength = 50;

  // ── Step 3: pricing ─────────────────────────────────────────────────
  final basePriceValue = 5000.0.obs;
  final guestServiceFeePercent = 10.0.obs;
  final hostServiceFeePercent = 4.0.obs;

  final seasonPercent = 100.0.obs;
  final startingDiscountPercent = 40.0.obs;
  final offSeasonDiscountPercent = 20.0.obs;

  /// Days marked as season / off season, keyed by `yyyy-mm-dd`.
  final seasonDays = <String>{}.obs;
  final offSeasonDays = <String>{}.obs;

  final bookingType = PartnerBookingType.reviewFirst.obs;

  // ── Step 4: verification ────────────────────────────────────────────
  final partnerNameField = TextEditingController();
  final partnerEmailField = TextEditingController();

  final phoneNumber = TextEditingController();
  final dialCode = '91'.obs;
  final isPhoneVerified = false.obs;

  /// "Add your number" OTP state — `/api/auth/phone/otp` and `/phone/verify`.
  final phoneCode = TextEditingController();
  final isOtpSent = false.obs;
  final isSendingOtp = false.obs;
  final isVerifyingOtp = false.obs;
  final otpError = ''.obs;
  final secondsUntilResend = 0.obs;

  /// Present only while the server exposes codes for local testing.
  final otpDevCode = RxnString();

  /// The number the current code was sent to — verify must use the same one.
  String _otpPhone = '';
  Timer? _resendTicker;

  static const identityDocuments = [
    'Driving licence',
    'Aadhaar card',
    'Pan card',
    'Passport',
  ];
  final selectedDocument = RxnInt();
  final isIdentityVerified = false.obs;
  final isLicenceVerified = false.obs;

  /// The capture screen is shared: true while it is taking the activity
  /// licence rather than the government ID.
  final capturingLicence = false.obs;
  final isUploadingDocument = false.obs;

  /// Uploaded document URLs (purpose "document"), sent with the application.
  String _identityDocumentUrl = '';
  String _licenceDocumentUrl = '';

  /// Local path of the photo just captured, previewed on the capture screen.
  final capturedPreviewPath = ''.obs;

  // ── Derived state ───────────────────────────────────────────────────

  /// 1-4 for the headline step, or null on screens outside the progress.
  int? get majorStep {
    return switch (step.value) {
      OnboardingStep.welcome => null,
      OnboardingStep.placeIntro ||
      OnboardingStep.activityType ||
      OnboardingStep.location ||
      OnboardingStep.address ||
      OnboardingStep.planDetails ||
      OnboardingStep.slots =>
        1,
      OnboardingStep.standOutIntro ||
      OnboardingStep.listingName ||
      OnboardingStep.listingDetails ||
      OnboardingStep.facilities ||
      OnboardingStep.photos =>
        2,
      OnboardingStep.pricingIntro ||
      OnboardingStep.basePrice ||
      OnboardingStep.seasonPricing ||
      OnboardingStep.discounts ||
      OnboardingStep.bookingType =>
        3,
      OnboardingStep.finishIntro ||
      OnboardingStep.aboutYou ||
      OnboardingStep.proof =>
        4,
      _ => null,
    };
  }

  String? get progressLabel {
    final major = majorStep;
    return major == null ? null : '$major / 4';
  }

  /// Guest-facing price, i.e. what the traveller is charged before tax.
  double get guestPrice =>
      basePriceValue.value * (1 + guestServiceFeePercent.value / 100);

  /// What lands in the partner's account after the host service fee.
  double get partnerEarnings =>
      basePriceValue.value * (1 - hostServiceFeePercent.value / 100);

  /// Whether the current screen has enough information to advance.
  bool get canAdvance {
    return switch (step.value) {
      OnboardingStep.activityType => selectedActivityType.value != null,
      OnboardingStep.location => locationQuery.text.trim().isNotEmpty,
      OnboardingStep.address => addressLine1.text.trim().isNotEmpty,
      OnboardingStep.listingName => listingTitle.text.trim().isNotEmpty,
      OnboardingStep.photos => photoPaths.length >= minimumPhotos,
      OnboardingStep.aboutYou =>
        partnerNameField.text.trim().isNotEmpty &&
            partnerEmailField.text.trim().isNotEmpty,
      OnboardingStep.proof => isPhoneVerified.value &&
          isIdentityVerified.value &&
          isLicenceVerified.value,
      _ => true,
    };
  }

  @override
  void onClose() {
    _resendTicker?.cancel();
    _searchDebounce?.cancel();
    for (final field in [
      phoneCode,
      locationQuery,
      addressLine1,
      addressLine2,
      city,
      state,
      pincode,
      listingTitle,
      listingDescription,
      instructionDraft,
      partnerNameField,
      partnerEmailField,
      phoneNumber,
    ]) {
      field.dispose();
    }
    super.onClose();
  }

  // ── Navigation ──────────────────────────────────────────────────────

  static const _order = OnboardingStep.values;

  void next() {
    if (!canAdvance) {
      return;
    }
    if (step.value == OnboardingStep.proof) {
      publish();
      return;
    }
    // The verification sub-screens return to `proof` rather than running on
    // into the next enum value.
    if (step.value == OnboardingStep.phoneEntry ||
        step.value == OnboardingStep.identityType ||
        step.value == OnboardingStep.identityCapture) {
      step.value = OnboardingStep.proof;
      return;
    }
    final index = _order.indexOf(step.value);
    if (index < _order.length - 1) {
      step.value = _order[index + 1];
    }
  }

  void back() {
    switch (step.value) {
      case OnboardingStep.welcome:
        Get.back();
      case OnboardingStep.phoneEntry:
      case OnboardingStep.identityType:
        step.value = OnboardingStep.proof;
      case OnboardingStep.identityCapture:
        step.value = capturingLicence.value
            ? OnboardingStep.proof
            : OnboardingStep.identityType;
      default:
        final index = _order.indexOf(step.value);
        step.value = _order[index - 1];
    }
  }

  void goTo(OnboardingStep target) => step.value = target;

  /// Leaves the wizard, keeping everything entered so far on this device.
  /// The draft is restored the next time the wizard opens.
  Future<void> saveAndExit() async {
    try {
      await _draftStorage.write(
        key: _draftKey,
        value: jsonEncode(_draftJson()),
      );
    } catch (error) {
      Get.log('Saving the onboarding draft failed: $error');
    }
    Get.back();
    _snack('Draft saved', 'Pick up where you left off next time.');
  }

  // ── Draft ───────────────────────────────────────────────────────────

  static const _draftKey = 'triptriva.partnerOnboardingDraft';
  static const _draftStorage = FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _restoreDraft();
  }

  Map<String, dynamic> _draftJson() => {
        'step': step.value.name,
        'activityType': selectedActivityType.value,
        'location': locationQuery.text,
        'address1': addressLine1.text,
        'address2': addressLine2.text,
        'city': city.text,
        'state': state.text,
        'pincode': pincode.text,
        'precise': showPreciseLocation.value,
        'guests': guests.value,
        'bedrooms': bedrooms.value,
        'beds': beds.value,
        'bathrooms': bathrooms.value,
        'slots': [
          for (final slot in slots) {'start': slot.start, 'end': slot.end},
        ],
        'facilities': selectedFacilities.toList(),
        'photos': photoPaths.toList(),
        'title': listingTitle.text,
        'description': listingDescription.text,
        'instructions': instructions.toList(),
        'basePrice': basePriceValue.value,
        'seasonPercent': seasonPercent.value,
        'startingDiscount': startingDiscountPercent.value,
        'offSeasonDiscount': offSeasonDiscountPercent.value,
        'seasonDays': seasonDays.toList(),
        'offSeasonDays': offSeasonDays.toList(),
        'bookingType': bookingType.value.name,
        'partnerName': partnerNameField.text,
        'partnerEmail': partnerEmailField.text,
        'phone': phoneNumber.text,
        'dialCode': dialCode.value,
        'phoneVerified': isPhoneVerified.value,
        'document': selectedDocument.value,
        'identityUrl': _identityDocumentUrl,
        'lat': pinnedPoint.value?.latitude,
        'lng': pinnedPoint.value?.longitude,
        'licenceUrl': _licenceDocumentUrl,
      };

  Future<void> _restoreDraft() async {
    Map<String, dynamic> d;
    try {
      final raw = await _draftStorage.read(key: _draftKey);
      if (raw == null || raw.isEmpty) return;
      d = (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (error) {
      Get.log('Reading the onboarding draft failed: $error');
      return;
    }

    String text(String key) => d[key] is String ? d[key] as String : '';
    int count(String key, int fallback) =>
        d[key] is num ? (d[key] as num).toInt() : fallback;
    double number(String key, double fallback) =>
        d[key] is num ? (d[key] as num).toDouble() : fallback;
    List<String> strings(String key) => d[key] is List
        ? (d[key] as List).whereType<String>().toList()
        : const [];

    selectedActivityType.value =
        d['activityType'] is int ? d['activityType'] as int : null;
    locationQuery.text = text('location');
    addressLine1.text = text('address1');
    addressLine2.text = text('address2');
    city.text = text('city');
    state.text = text('state');
    pincode.text = text('pincode');
    showPreciseLocation.value = d['precise'] != false;
    guests.value = count('guests', 1);
    bedrooms.value = count('bedrooms', 1);
    beds.value = count('beds', 1);
    bathrooms.value = count('bathrooms', 1);
    final savedSlots = d['slots'];
    if (savedSlots is List && savedSlots.isNotEmpty) {
      slots.assignAll([
        for (final slot in savedSlots.whereType<Map>())
          (start: '${slot['start'] ?? ''}', end: '${slot['end'] ?? ''}'),
      ]);
    }
    selectedFacilities.assignAll(strings('facilities'));
    // Picked photos sit in a temp folder the OS may have cleared since.
    photoPaths.assignAll(
      strings('photos').where((path) => File(path).existsSync()),
    );
    listingTitle.text = text('title');
    listingDescription.text = text('description');
    instructions.assignAll(strings('instructions'));
    basePriceValue.value = number('basePrice', basePriceValue.value);
    seasonPercent.value = number('seasonPercent', seasonPercent.value);
    startingDiscountPercent.value =
        number('startingDiscount', startingDiscountPercent.value);
    offSeasonDiscountPercent.value =
        number('offSeasonDiscount', offSeasonDiscountPercent.value);
    seasonDays.assignAll(strings('seasonDays'));
    offSeasonDays.assignAll(strings('offSeasonDays'));
    bookingType.value = PartnerBookingType.values.firstWhere(
      (type) => type.name == d['bookingType'],
      orElse: () => PartnerBookingType.reviewFirst,
    );
    partnerNameField.text = text('partnerName');
    partnerEmailField.text = text('partnerEmail');
    phoneNumber.text = text('phone');
    if (text('dialCode').isNotEmpty) dialCode.value = text('dialCode');
    isPhoneVerified.value = d['phoneVerified'] == true;
    selectedDocument.value = d['document'] is int ? d['document'] as int : null;
    _identityDocumentUrl = text('identityUrl');
    _licenceDocumentUrl = text('licenceUrl');
    pinnedPoint.value = GeoPoint.tryParse(d['lat'], d['lng']);
    isIdentityVerified.value = _identityDocumentUrl.isNotEmpty;
    isLicenceVerified.value = _licenceDocumentUrl.isNotEmpty;

    final saved = OnboardingStep.values.firstWhere(
      (value) => value.name == d['step'],
      orElse: () => OnboardingStep.welcome,
    );
    // Verification sub-screens reopen on their parent checklist.
    step.value = switch (saved) {
      OnboardingStep.phoneEntry ||
      OnboardingStep.identityType ||
      OnboardingStep.identityCapture =>
        OnboardingStep.proof,
      _ => saved,
    };
  }

  Future<void> _clearDraft() async {
    try {
      await _draftStorage.delete(key: _draftKey);
    } catch (error) {
      Get.log('Clearing the onboarding draft failed: $error');
    }
  }

  void openHelp() => Get.toNamed(Routes.CUSTOMER_SUPPORT);

  // ── Field updates ───────────────────────────────────────────────────

  void selectActivityType(int index) => selectedActivityType.value = index;

  void toggleFacility(String facility) {
    if (selectedFacilities.contains(facility)) {
      selectedFacilities.remove(facility);
    } else {
      selectedFacilities.add(facility);
    }
  }

  void adjustGuests(int delta) => guests.value = (guests.value + delta).clamp(1, 50);
  void adjustBedrooms(int delta) =>
      bedrooms.value = (bedrooms.value + delta).clamp(0, 30);
  void adjustBeds(int delta) => beds.value = (beds.value + delta).clamp(0, 50);
  void adjustBathrooms(int delta) =>
      bathrooms.value = (bathrooms.value + delta).clamp(0, 30);

  void addSlot() =>
      slots.add((start: '00 : 00 AM', end: '00 : 00 AM'));

  void removeSlot(int index) {
    if (slots.length > 1) {
      slots.removeAt(index);
    }
  }

  void updateSlot(int index, {String? start, String? end}) {
    final slot = slots[index];
    slots[index] = (start: start ?? slot.start, end: end ?? slot.end);
  }

  void addInstruction() {
    final text = instructionDraft.text.trim();
    if (text.isEmpty) {
      return;
    }
    instructions.add(text);
    instructionDraft.clear();
  }

  void removeInstruction(String instruction) =>
      instructions.remove(instruction);

  /// Records a picked photo. The picker itself lives in the view so this stays
  /// testable without a platform channel.
  void addPhoto(String path) => photoPaths.add(path);

  void removePhoto(String path) => photoPaths.remove(path);

  void setBasePrice(double value) => basePriceValue.value = value;

  void setSeasonPercent(double value) => seasonPercent.value = value;

  void selectBookingType(PartnerBookingType type) => bookingType.value = type;

  void toggleSeasonDay(String key, {required bool offSeason}) {
    final target = offSeason ? offSeasonDays : seasonDays;
    if (target.contains(key)) {
      target.remove(key);
    } else {
      target.add(key);
    }
  }

  void selectDocument(int index) {
    selectedDocument.value = index;
    capturingLicence.value = false;
    capturedPreviewPath.value = '';
    step.value = OnboardingStep.identityCapture;
  }

  void openLicenceCapture() {
    capturingLicence.value = true;
    capturedPreviewPath.value = '';
    step.value = OnboardingStep.identityCapture;
  }

  /// Uploads the photo of the ID or licence (purpose "document"); it is
  /// attached to the partner application for the admin to review.
  Future<void> uploadDocument(String path) async {
    capturedPreviewPath.value = path;
    isUploadingDocument.value = true;
    try {
      final result =
          await Get.find<MediaService>().upload(path, purpose: 'document');
      final url = result is Map ? '${result['fileUrl'] ?? ''}' : '';
      if (url.isEmpty) {
        _snack('Upload failed', 'Please try again.');
        return;
      }
      if (capturingLicence.value) {
        _licenceDocumentUrl = url;
        isLicenceVerified.value = true;
      } else {
        _identityDocumentUrl = url;
        isIdentityVerified.value = true;
      }
      step.value = OnboardingStep.proof;
    } on ApiException catch (error) {
      _snack('Upload failed', error.message);
    } finally {
      isUploadingDocument.value = false;
    }
  }

  /// E.164 form of what's typed: the dial code plus the local digits.
  String get _fullPhone {
    final digits = phoneNumber.text.replaceAll(RegExp(r'\D'), '');
    return '+${dialCode.value}$digits';
  }

  bool get canSendOtp =>
      phoneNumber.text.replaceAll(RegExp(r'\D'), '').length >= 10 &&
      !isSendingOtp.value &&
      secondsUntilResend.value == 0;

  /// Texts a code to the typed number. Also used for "Resend".
  Future<void> sendPhoneOtp() async {
    if (!canSendOtp) {
      return;
    }
    isSendingOtp.value = true;
    otpError.value = '';
    try {
      final phone = _fullPhone;
      final result = await _authService.requestPhoneOtp(phone);
      _otpPhone = phone;
      otpDevCode.value = result['devCode'] as String?;
      phoneCode.clear();
      isOtpSent.value = true;
      _startResendCooldown(
        (result['resendAfterSeconds'] as num?)?.toInt() ?? 60,
      );
    } on ApiException catch (error) {
      // 409 (number on another account) and 429 (cooldown) read well as-is.
      otpError.value = error.message;
    } finally {
      isSendingOtp.value = false;
    }
  }

  /// Editing the number after a code was sent starts over.
  void onPhoneChanged() {
    if (isOtpSent.value && _fullPhone != _otpPhone) {
      isOtpSent.value = false;
      phoneCode.clear();
      otpDevCode.value = null;
    }
    otpError.value = '';
    step.refresh();
  }

  Future<void> verifyPhoneOtp() async {
    final code = phoneCode.text.trim();
    if (code.length != 6 || isVerifyingOtp.value) {
      return;
    }
    isVerifyingOtp.value = true;
    otpError.value = '';
    try {
      await _authService.verifyPhone(phone: _otpPhone, code: code);
      _resendTicker?.cancel();
      secondsUntilResend.value = 0;
      isPhoneVerified.value = true;
      step.value = OnboardingStep.proof;
    } on ApiException catch (error) {
      otpError.value = error.message;
      phoneCode.clear();
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  void _startResendCooldown(int seconds) {
    _resendTicker?.cancel();
    secondsUntilResend.value = seconds;
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsUntilResend.value <= 1) {
        secondsUntilResend.value = 0;
        timer.cancel();
        return;
      }
      secondsUntilResend.value--;
    });
  }

  // ── Submit ──────────────────────────────────────────────────────────

  /// Backend listing type for each entry of [activityTypes]. Fresh-up rooms
  /// are sold as stays.
  static const _backendTypes = ['houseboat', 'adventure', 'stay', 'stay'];

  String get _backendType {
    final index = selectedActivityType.value;
    return index == null ? 'stay' : _backendTypes[index];
  }

  /// Sends the finished listing for review. Admin approval is what actually
  /// makes it visible to travellers.
  ///
  /// Only partners can list. A user who isn't one yet gets a partner
  /// application from the details they entered here instead; they add the
  /// listing once an admin approves them.
  Future<void> publish() async {
    final problem = _validate();
    if (problem != null) {
      _snack('Check your details', problem);
      return;
    }

    isSubmitting.value = true;
    try {
      final me = await _partnerService.getProfile();

      if (me['isPartner'] != true) {
        await _applyToBecomePartner('${me['applicationStatus'] ?? 'none'}');
        return;
      }

      // An approval after sign-in isn't on the current access token yet;
      // a fresh one carries the partner role.
      await _authService.refreshSession();

      final imageUrls = await _uploadPhotos();
      await _partnerService.createListing(_listingPayload(imageUrls));

      _partnerService.clearCache();
      await _clearDraft();
      Get.back(result: true);
      _snack(
        'Submitted',
        'Your listing is under review. We will notify you once it is approved.',
      );
    } on ApiException catch (error) {
      _snack('Could not submit', error.message);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _applyToBecomePartner(String status) async {
    if (status == 'pending') {
      _snack(
        'Application in review',
        'Your partner application is still being reviewed. You can add '
            'listings once it is approved.',
      );
      return;
    }

    await _partnerService.apply({
      'businessName': listingTitle.text.trim(),
      'listingTypes': [_backendType],
      'contactName': partnerNameField.text.trim(),
      'contactPhone': '+${dialCode.value}${phoneNumber.text.trim()}',
      'contactEmail': partnerEmailField.text.trim(),
      'addressLine': _addressLine,
      'city': city.text.trim(),
      'state': state.text.trim(),
      'pincode': pincode.text.trim(),
      'description': listingDescription.text.trim(),
      'identityDocumentType': ?_identityDocumentType,
      'documentUrls': [
        if (_identityDocumentUrl.isNotEmpty) _identityDocumentUrl,
        if (_licenceDocumentUrl.isNotEmpty) _licenceDocumentUrl,
      ],
    });

    // The listing itself is only created after approval: keep what was
    // entered so "Add Activity" reopens with it filled in.
    try {
      await _draftStorage.write(key: _draftKey, value: jsonEncode(_draftJson()));
    } catch (error) {
      Get.log('Saving the onboarding draft failed: $error');
    }
    Get.back(result: true);
    _snack(
      'Application sent',
      'We are reviewing your partner application. Once approved, open Add '
          'Activity again — your details are saved — and publish.',
    );
  }

  /// Photos go up first: a listing may only reference the partner's own uploads.
  Future<List<String>> _uploadPhotos() async {
    final media = Get.find<MediaService>();
    final urls = <String>[];
    for (final path in photoPaths) {
      final result = await media.upload(path, purpose: 'listing');
      final url = result is Map ? result['fileUrl'] : null;
      if (url is String && url.isNotEmpty) urls.add(url);
    }
    return urls;
  }

  String? get _identityDocumentType {
    final index = selectedDocument.value;
    return index == null ? null : identityDocuments[index];
  }

  String get _addressLine => [addressLine1.text, addressLine2.text]
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join(', ');

  /// Mirrors the backend's rules so the partner gets a clear message before
  /// anything is uploaded.
  String? _validate() {
    final title = listingTitle.text.trim();
    if (title.length < 5) return 'The listing name needs at least 5 characters.';
    if (listingDescription.text.trim().length < 20) {
      return 'The description needs at least 20 characters.';
    }
    if (city.text.trim().length < 2) return 'Enter the city.';
    if (state.text.trim().isEmpty) return 'Enter the state.';
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode.text.trim())) {
      return 'Enter a 6-digit PIN code.';
    }
    if (basePriceValue.value <= 0) return 'Set a base price.';
    return null;
  }

  Map<String, dynamic> _listingPayload(List<String> imageUrls) {
    final slotTimes = slots
        .map((slot) => (start: _to24h(slot.start), end: _to24h(slot.end)))
        .where((slot) => slot.start != null && slot.end != null)
        .toList();

    return {
      'type': _backendType,
      'title': listingTitle.text.trim(),
      'description': listingDescription.text.trim(),
      'address': _addressLine,
      'city': city.text.trim(),
      'state': state.text.trim(),
      'pincode': pincode.text.trim(),
      'basePrice': basePriceValue.value,
      'discountPercent': 0,
      'maxGuests': guests.value,
      'bedrooms': bedrooms.value,
      'beds': beds.value,
      'bathrooms': bathrooms.value,
      ..._coordinates,
      if (imageUrls.isNotEmpty) 'coverImage': imageUrls.first,
      'images': imageUrls,
      'amenities': selectedFacilities.toList(),
      'houseRules': instructions.toList(),
      // The first slot's window, as the listing's check-in/out times.
      if (slotTimes.isNotEmpty) 'checkInTime': slotTimes.first.start,
      if (slotTimes.isNotEmpty) 'checkOutTime': slotTimes.first.end,
    };
  }

  /// "09 : 30 PM" → "21:30"; null for the untouched "00 : 00 AM" placeholder
  /// or anything unparseable.
  static String? _to24h(String value) {
    final match = RegExp(r'^(\d{1,2})\s*:\s*(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final pm = match.group(3)!.toUpperCase() == 'PM';
    if (hour == 0 && minute == 0 && !pm) return null;
    if (hour > 12 || minute > 59) return null;
    if (hour == 12) hour = 0;
    if (pm) hour += 12;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void _snack(String title, String message) =>
      Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
}
