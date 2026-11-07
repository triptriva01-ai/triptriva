import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_wizard_scaffold.dart';
import '../controllers/partner_onboarding_controller.dart';
import '../widgets/onboarding_intro_steps.dart';
import '../widgets/onboarding_place_steps.dart';
import '../widgets/onboarding_pricing_steps.dart';
import '../widgets/onboarding_standout_steps.dart';
import '../widgets/onboarding_verify_steps.dart';

/// Partner listing creation — Sheet2 Page 01, "Add Activity".
///
/// One scaffold hosts every step so the Save & Exit / Back / Next chrome stays
/// put while only the body changes.
class PartnerOnboardingView extends GetView<PartnerOnboardingController> {
  const PartnerOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.step.value;

      return PopScope(
        // Back should step within the wizard, not drop the partner out of it.
        canPop: step == OnboardingStep.welcome,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            controller.back();
          }
        },
        child: PartnerWizardScaffold(
          onSaveAndExit: controller.saveAndExit,
          onHelp: controller.openHelp,
          onBack: controller.back,
          onNext: controller.canAdvance && !controller.isSubmitting.value
              ? controller.next
              : null,
          progressLabel: controller.progressLabel,
          nextLabel: _nextLabel(step),
          showFooterNav: step != OnboardingStep.welcome,
          child: _body(step),
        ),
      );
    });
  }

  String _nextLabel(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => 'Get started',
      OnboardingStep.proof => 'Publish',
      _ => 'Next',
    };
  }

  Widget _body(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => const OnboardingWelcomeStep(),
      OnboardingStep.placeIntro => const OnboardingIntroStep(stepIndex: 0),
      OnboardingStep.activityType => ActivityTypeStep(controller: controller),
      OnboardingStep.location => LocationStep(controller: controller),
      OnboardingStep.address => AddressStep(controller: controller),
      OnboardingStep.planDetails => PlanDetailsStep(controller: controller),
      OnboardingStep.slots => SlotsStep(controller: controller),
      OnboardingStep.standOutIntro => const OnboardingIntroStep(stepIndex: 1),
      OnboardingStep.listingName => ListingNameStep(controller: controller),
      OnboardingStep.listingDetails =>
        ListingDetailsStep(controller: controller),
      OnboardingStep.facilities => FacilitiesStep(controller: controller),
      OnboardingStep.photos => PhotosStep(controller: controller),
      OnboardingStep.pricingIntro => const OnboardingIntroStep(stepIndex: 2),
      OnboardingStep.basePrice => BasePriceStep(controller: controller),
      OnboardingStep.seasonPricing =>
        SeasonPricingStep(controller: controller),
      OnboardingStep.discounts => DiscountsStep(controller: controller),
      OnboardingStep.bookingType => BookingTypeStep(controller: controller),
      OnboardingStep.finishIntro => const OnboardingIntroStep(stepIndex: 3),
      OnboardingStep.aboutYou => AboutYouStep(controller: controller),
      OnboardingStep.proof => ProofStep(controller: controller),
      OnboardingStep.phoneEntry => PhoneEntryStep(controller: controller),
      OnboardingStep.identityType => IdentityTypeStep(controller: controller),
      OnboardingStep.identityCapture =>
        IdentityCaptureStep(controller: controller),
    };
  }
}
