import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/notifications_constants.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_tabs.dart';
import '../widgets/notification_tile.dart';

/// Notification screen.
class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: NotificationsPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: NotificationsPalette.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NotificationsSizes.pagePadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: NotificationsSizes.headerTop),
                _Header(onBack: controller.goBack),
                const SizedBox(height: NotificationsSizes.headerToTabs),
                NotificationTabs(controller: controller),
                const SizedBox(height: NotificationsSizes.tabsToList),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = controller.visibleNotifications;
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          NotificationsStrings.empty,
                          style: NotificationsStyle.message,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.loadNotifications,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          bottom: NotificationsSizes.listBottomPadding,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: NotificationsSizes.itemGap,
                          ),
                          child: NotificationDivider(),
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return NotificationTile(
                            notification: item,
                            onTap: () => controller.openNotification(item),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const SizedBox(
            width: NotificationsSizes.backButtonSize,
            height: NotificationsSizes.backButtonSize,
            child: Icon(
              Icons.arrow_back_ios_new,
              size: NotificationsSizes.backIconSize,
              color: NotificationsPalette.black,
            ),
          ),
        ),
        const SizedBox(width: NotificationsSizes.backToTitle),
        const Expanded(
          child: Text(
            NotificationsStrings.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NotificationsStyle.title,
          ),
        ),
      ],
    );
  }
}
