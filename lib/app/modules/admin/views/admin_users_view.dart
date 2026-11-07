import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user.dart';
import '../constants/admin_constants.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_shell.dart';

/// Admin — user directory.
class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdminShell(
        title: AdminStrings.users,
        currentIndex: controller.currentTab.value,
        onTabSelected: controller.onTabSelected,
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AdminSizes.pagePadding,
              16,
              AdminSizes.pagePadding,
              AdminSizes.listBottomPadding,
            ),
            children: [
              Obx(
                () => AdminFilterChips(
                  labels: AdminUsersController.filters,
                  selectedIndex: controller.selectedFilter.value,
                  onSelected: controller.selectFilter,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = controller.users.toList();
                if (users.isEmpty) {
                  return const Text(
                    AdminStrings.empty,
                    style: AdminStyle.cardMeta,
                  );
                }

                return Column(
                  children: [
                    for (final user in users) ...[
                      _UserCard(
                        user: user,
                        onTap: () => controller.openUser(user),
                      ),
                      const SizedBox(height: AdminSizes.listGap),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  /// "Partner" rows carry the brand green; ordinary accounts stay neutral.
  bool get _isPartner => user.isPartner;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AdminCard(
        padding: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              AdminAvatar(
                imageUrl: user.avatarUrl ?? '',
                size: AdminSizes.avatarSize,
                radius: 20,
              ),
              const SizedBox(width: 8),
              // Takes the slack so a long name ellipsises rather than
              // pushing the chevron off the edge.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminStyle.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPartner
                              ? Icons.storefront_outlined
                              : Icons.person_outline,
                          size: 12,
                          color: _isPartner
                              ? AdminPalette.green
                              : AdminPalette.black,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _isPartner ? 'Partner' : 'Normal user',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _isPartner
                                ? AdminStyle.cardCategory
                                : AdminStyle.cardOwner,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AdminPalette.navInactive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
