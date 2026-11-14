import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../constants/admin_constants.dart';
import '../controllers/admin_profile_controller.dart';
import '../widgets/admin_shell.dart';

/// Admin — profile, with the edit form behind "Edit Profile".
class AdminProfileView extends GetView<AdminProfileController> {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdminShell(
        title: controller.isEditing.value
            ? AdminStrings.editProfile
            : AdminStrings.admin,
        currentIndex: controller.currentTab.value,
        onTabSelected: controller.onTabSelected,
        child: Obx(
          () => controller.isEditing.value
              ? _EditForm(controller: controller)
              : _Settings(controller: controller),
        ),
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings({required this.controller});

  final AdminProfileController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AdminSizes.pagePadding,
        16,
        AdminSizes.pagePadding,
        AdminSizes.listBottomPadding,
      ),
      children: [
        Obx(() {
          final user = controller.user.value;
          return _ProfileCard(
            name: user?.name ?? '',
            phone: user?.phone ?? '',
            avatarUrl: user?.avatarUrl ?? '',
          );
        }),
        const SizedBox(height: AdminSizes.listGap),
        _ActionCard(
          icon: Icons.edit_outlined,
          label: AdminStrings.editProfile,
          onTap: controller.startEditing,
        ),
        const SizedBox(height: 34),
        const Text(
          AdminStrings.accountsSection,
          style: AdminStyle.settingsSection,
        ),
        const SizedBox(height: 30),
        _SettingsRow(
          icon: Icons.credit_card,
          label: AdminStrings.paymentMethod,
          onTap: () => Get.toNamed(Routes.PAYMENT_METHODS),
        ),
        const _RowDivider(),
        _SettingsRow(
          icon: Icons.language,
          label: AdminStrings.language,
          onTap: () => Get.toNamed(Routes.LANGUAGE),
        ),
        const _RowDivider(),
        _SettingsRow(
          icon: Icons.chat_bubble_outline,
          label: AdminStrings.feedbacks,
          onTap: () => Get.toNamed(Routes.FEEDBACK),
        ),
        const _RowDivider(),
        const SizedBox(height: 40),
        Center(
          child: _GradientButton(
            label: AdminStrings.logOut,
            onTap: controller.logout,
          ),
        ),
      ],
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({required this.controller});

  final AdminProfileController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AdminSizes.pagePadding,
        16,
        AdminSizes.pagePadding,
        AdminSizes.listBottomPadding,
      ),
      children: [
        Obx(() {
          final user = controller.user.value;
          return _ProfileCard(
            name: '',
            phone: '',
            avatarUrl: user?.avatarUrl ?? '',
            onChangePicture: controller.changePicture,
          );
        }),
        const SizedBox(height: 22),
        _Field(
          label: AdminStrings.fieldUsername,
          controller: controller.nameController,
        ),
        const SizedBox(height: 22),
        _Field(
          label: AdminStrings.fieldEmail,
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 22),
        _Field(
          label: AdminStrings.fieldPhone,
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 40),
        Center(
          child: Obx(
            () => _GradientButton(
              label: AdminStrings.update,
              onTap: controller.isSaving.value ? null : controller.save,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: controller.stopEditing,
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}

/// The avatar card: brand gradient washed out to white behind a round photo.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    this.onChangePicture,
  });

  final String name;
  final String phone;
  final String avatarUrl;
  final VoidCallback? onChangePicture;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: AdminGradients.profileCard,
        borderRadius: BorderRadius.circular(AdminSizes.sheetRadius),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AdminPalette.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x1A000000), blurRadius: 24),
              ],
            ),
            child: AdminAvatar(imageUrl: avatarUrl, size: 138),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AdminStyle.profileName,
            ),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(phone, style: AdminStyle.profilePhone),
          ],
          if (onChangePicture != null) ...[
            const SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onChangePicture,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    AdminStrings.changePicture,
                    style: TextStyle(
                      color: AdminPalette.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.edit_outlined, size: 14),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // A minimum, not a cap.
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AdminPalette.white,
          borderRadius: BorderRadius.circular(AdminSizes.sheetRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 24),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AdminPalette.black),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminStyle.settingsRow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AdminPalette.black),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminStyle.settingsRow,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AdminPalette.fieldBorder,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(color: AdminPalette.hairline),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AdminStyle.fieldLabel),
        const SizedBox(height: 8),
        Container(
          // A minimum, not a cap: the field grows with the system font.
          constraints: const BoxConstraints(
            minHeight: AdminSizes.fieldMinHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(color: AdminPalette.fieldBorder),
            borderRadius: BorderRadius.circular(AdminSizes.fieldRadius),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AdminStyle.fieldValue,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;

  /// Null greys the button out.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 49, minWidth: 104),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: onTap == null ? null : AdminGradients.prime,
          color: onTap == null ? AdminPalette.fieldBorder : null,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AdminStyle.cta,
        ),
      ),
    );
  }
}
