import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/profile/logout_button.dart';
import '../../../widgets/profile/profile_band.dart';
import '../../../widgets/profile/profile_info_card.dart';
import '../../../widgets/profile/profile_settings_row.dart';
import '../../../widgets/profile/profile_theme.dart';
import '../constants/partner_profile_constants.dart';
import '../controllers/partner_profile_controller.dart';

/// Partner-side Page 06 — Profile.
class PartnerProfileView extends GetView<PartnerProfileController> {
  const PartnerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: ProfilePalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ProfilePalette.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: PartnerProfileSizes.headerTopSpacing),
              _Header(controller: controller),
              const SizedBox(height: PartnerProfileSizes.headerToCard),
              Expanded(
                child: SingleChildScrollView(
                  child: _Content(controller: controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back arrow + page title (the partner profile has no notification bell).
class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final PartnerProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProfileSizes.pagePadding,
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.goBack,
            child: const Icon(
              Icons.arrow_back,
              size: PartnerProfileSizes.backIconSize,
              color: ProfilePalette.black,
            ),
          ),
          const SizedBox(width: PartnerProfileSizes.backIconToTitle),
          const Expanded(
            child: Text(
              PartnerProfileStrings.title,
              style: ProfileStyle.pageTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final PartnerProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSheet(
          above: true,
          child: Column(
            children: [
              Obx(
                () => ProfileInfoCard(
                  name: controller.name.value,
                  phone: controller.phone.value,
                  imageUrl: controller.avatarUrl.value,
                ),
              ),
              const SizedBox(height: PartnerProfileSizes.cardToBand),
            ],
          ),
        ),
        // FR-02 — back to the traveller side of the platform.
        ProfileBand(
          onTap: controller.backToTripTrivia,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text.rich(
                  TextSpan(
                    style: ProfileStyle.bandLight,
                    children: [
                      TextSpan(text: PartnerProfileStrings.backToLead),
                      TextSpan(text: PartnerProfileStrings.brandLight),
                      TextSpan(
                        text: PartnerProfileStrings.brandBold,
                        style: ProfileStyle.bandBold,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: ProfileSizes.bandHorizontalPadding),
              const Icon(
                Icons.chevron_right,
                size: ProfileSizes.chevronSize,
                color: ProfilePalette.blue,
              ),
            ],
          ),
        ),
        ProfileSheet(
          above: false,
          child: _AccountsSection(controller: controller),
        ),
      ],
    );
  }
}

class _AccountsSection extends StatelessWidget {
  const _AccountsSection({required this.controller});

  final PartnerProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: ProfileSizes.sheetTopPadding),
        const Text(
          PartnerProfileStrings.accountsSection,
          style: ProfileStyle.sectionLabel,
        ),
        const SizedBox(height: ProfileSizes.sectionLabelToRows),

        // FR-03 — payment methods and payout details.
        ProfileSettingsRow(
          icon: Icons.credit_card,
          label: PartnerProfileStrings.paymentMethod,
          onTap: controller.openPaymentMethods,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.groupGap),

        ProfileSettingsRow(
          icon: Icons.translate,
          label: PartnerProfileStrings.language,
          onTap: controller.openLanguage,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.rowToDivider),

        ProfileSettingsRow(
          icon: Icons.chat_bubble,
          label: PartnerProfileStrings.feedback,
          onTap: controller.openFeedback,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.rowToDivider),

        ProfileSettingsRow(
          icon: Icons.privacy_tip,
          label: PartnerProfileStrings.dataPrivacy,
          onTap: controller.openDataPrivacy,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.rowToDivider),

        ProfileSettingsRow(
          icon: Icons.headset_mic,
          label: PartnerProfileStrings.customerSupport,
          onTap: controller.openCustomerSupport,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.rowToDivider),

        ProfileSettingsRow(
          icon: Icons.info,
          label: PartnerProfileStrings.about,
          onTap: controller.openAbout,
        ),

        const SizedBox(height: ProfileSizes.rowsToLogout),
        Center(
          child: LogoutButton(
            label: PartnerProfileStrings.logout,
            onTap: controller.logout,
          ),
        ),
        const SizedBox(height: ProfileSizes.logoutToBottom),
      ],
    );
  }
}
