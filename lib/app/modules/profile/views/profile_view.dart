import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/app_bottom_nav.dart';
import '../../../widgets/profile/logout_button.dart';
import '../../../widgets/profile/profile_band.dart';
import '../../../widgets/profile/profile_info_card.dart';
import '../../../widgets/profile/profile_settings_row.dart';
import '../../../widgets/profile/profile_theme.dart';
import '../constants/profile_constants.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_quick_actions.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

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
              const SizedBox(height: ProfileHeaderSizes.headerToCard),
              ProfileHeader(controller: controller),
              const SizedBox(height: ProfileHeaderSizes.headerToCard),
              Expanded(
                child: SingleChildScrollView(
                  child: _ProfileContent(controller: controller),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => AppBottomNav(
            currentIndex: controller.currentTab.value,
            onTap: controller.onTabSelected,
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.controller});

  final ProfileController controller;

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
              const SizedBox(height: ProfileHeaderSizes.cardToActions),
              ProfileQuickActions(controller: controller),
              const SizedBox(height: ProfileHeaderSizes.cardToActions),
            ],
          ),
        ),
        ProfileBand(
          onTap: controller.openPartnerRegistration,
          child: Row(
            children: [
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    style: ProfileStyle.bandLight,
                    children: [
                      TextSpan(text: ProfileStrings.partnerLead),
                      TextSpan(text: ProfileStrings.partnerBrandLight),
                      TextSpan(
                        text: ProfileStrings.partnerBrandBold,
                        style: ProfileStyle.bandBold,
                      ),
                      TextSpan(text: ProfileStrings.partnerTrail),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: ProfileSizes.sheetTopPadding),
        const Text(
          ProfileStrings.accountsSection,
          style: ProfileStyle.sectionLabel,
        ),
        const SizedBox(height: ProfileSizes.sectionLabelToRows),
        ProfileSettingsRow(
          icon: Icons.credit_card,
          label: ProfileStrings.paymentMethod,
          onTap: controller.openPaymentMethods,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.groupGap),
        ProfileSettingsRow(
          icon: Icons.translate,
          label: ProfileStrings.language,
          onTap: controller.openLanguage,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.rowToDivider),
        ProfileSettingsRow(
          icon: Icons.chat_bubble,
          label: ProfileStrings.feedback,
          onTap: controller.openFeedback,
        ),
        const SizedBox(height: ProfileSizes.rowToDivider),
        const ProfileSettingsDivider(),
        const SizedBox(height: ProfileSizes.rowToDivider),
        ProfileSettingsRow(
          icon: Icons.privacy_tip,
          label: ProfileStrings.dataPrivacy,
          onTap: controller.openDataPrivacy,
        ),
        // Only administrators see this row. It is a convenience, not a
        // control — AdminGuard turns away anyone who reaches the route some
        // other way, and the server checks the role on every request.
        Obx(() {
          if (!controller.isAdmin.value) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: ProfileSizes.rowToDivider),
              const ProfileSettingsDivider(),
              const SizedBox(height: ProfileSizes.rowToDivider),
              ProfileSettingsRow(
                icon: Icons.admin_panel_settings,
                label: ProfileStrings.adminPanel,
                onTap: controller.openAdminPanel,
              ),
            ],
          );
        }),
        const SizedBox(height: ProfileSizes.rowsToLogout),
        Center(
          child: LogoutButton(
            label: ProfileStrings.logout,
            onTap: controller.logout,
          ),
        ),
        const SizedBox(height: ProfileSizes.logoutToBottom),
      ],
    );
  }
}
