import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/app_bottom_nav.dart';
import '../../../widgets/listing/listing_grid.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/widgets/category_selector.dart';
import '../constants/search_constants.dart';
import '../controllers/search_controller.dart';

/// Page 6 — Search. Shows quick picks and recent searches until the user
/// types, then location suggestions.
class SearchView extends GetView<AppSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: SearchPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: SearchPalette.white,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: SearchSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The category row belongs to Home; reuse it while Home is
                // underneath so the selection stays in sync.
                if (Get.isRegistered<HomeController>())
                  CategorySelector(controller: Get.find<HomeController>()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SearchSizes.pagePadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SearchField(controller: controller),
                      const SizedBox(height: SearchSizes.fieldToCard),
                      Obx(() {
                        switch (controller.mode.value) {
                          case SearchMode.results:
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SearchActions(controller: controller),
                                const SizedBox(height: SearchSizes.cardToRecent),
                                _Results(controller: controller),
                              ],
                            );
                          case SearchMode.suggestions:
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SuggestionsCard(controller: controller),
                                const SizedBox(height: SearchSizes.cardToRecent),
                                _RecentSearches(controller: controller),
                              ],
                            );
                          case SearchMode.picks:
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _QuickPicksCard(controller: controller),
                                const SizedBox(height: SearchSizes.cardToRecent),
                                _RecentSearches(controller: controller),
                                _SearchActions(controller: controller),
                              ],
                            );
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SearchSizes.fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: SearchSizes.pagePadding),
      decoration: BoxDecoration(
        color: SearchPalette.white,
        border: Border.all(color: SearchPalette.border),
        borderRadius: BorderRadius.circular(SearchSizes.fieldRadius),
        boxShadow: SearchShadows.field,
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.goBack,
            child: const Icon(
              Icons.arrow_back,
              size: SearchSizes.fieldIconSize,
              color: SearchPalette.black,
            ),
          ),
          const SizedBox(width: SearchSizes.fieldIconGap),
          Expanded(
            child: TextField(
              controller: controller.textController,
              focusNode: controller.focusNode,
              onChanged: controller.onQueryChanged,
              onSubmitted: controller.submit,
              textInputAction: TextInputAction.search,
              style: SearchStyle.input,
              decoration: const InputDecoration(
                hintText: SearchStrings.hint,
                hintStyle: SearchStyle.input,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          Obx(
            () => controller.query.value.isNotEmpty
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.clear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.cancel,
                        size: SearchSizes.clearIconSize,
                        color: SearchPalette.clear,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: SearchSizes.fieldIconGap),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.startVoiceSearch,
            child: const Icon(
              Icons.mic,
              size: SearchSizes.fieldIconSize,
              color: SearchPalette.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// White rounded card that holds the rows under the field.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SearchSizes.cardPadding),
      decoration: BoxDecoration(
        color: SearchPalette.white,
        borderRadius: BorderRadius.circular(SearchSizes.cardRadius),
        boxShadow: SearchShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: SearchSizes.rowGap),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _QuickPicksCard extends StatelessWidget {
  const _QuickPicksCard({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    final mostSearched = controller.mostSearched.value;
    return _Card(
      children: [
        _SearchRow(
          leading: const _IconTile(
            icon: Icons.near_me_outlined,
            color: SearchPalette.green,
          ),
          title: SearchStrings.nearby,
          subtitle: SearchStrings.nearbySubtitle,
          onTap: controller.openNearby,
        ),
        _SearchRow(
          leading: const _IconTile(
            icon: Icons.event_available_outlined,
            color: SearchPalette.blue,
          ),
          title: SearchStrings.available,
          subtitle: SearchStrings.availableSubtitle,
          onTap: controller.openAvailable,
        ),
        if (mostSearched != null)
          _SearchRow(
            leading: _ImageTile(url: mostSearched.imageUrl),
            title: mostSearched.name,
            subtitle: SearchStrings.mostSearchedSubtitle,
            onTap: () => controller.openSuggestion(mostSearched),
          ),
      ],
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  const _SuggestionsCard({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.suggestions.toList();
    final typed = controller.query.value.trim();
    return _Card(
      children: [
        _SearchRow(
          leading: const _IconTile(icon: Icons.search, color: SearchPalette.green),
          title: typed,
          subtitle: SearchStrings.searchFor,
          onTap: () => controller.submit(typed),
        ),
        for (final item in items)
          _SearchRow(
            leading: _ImageTile(url: item.imageUrl),
            title: item.name,
            subtitle: item.stayCount == null
                ? ''
                : SearchStrings.stays(item.stayCount!),
            onTap: () => controller.openSuggestion(item),
            trailing: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.fillFrom(item),
              child: const Icon(
                Icons.north_east,
                size: SearchSizes.arrowSize,
                color: SearchPalette.black,
              ),
            ),
          ),
        Column(
          children: [
            if (items.isNotEmpty) ...[
              const Divider(height: 1, color: SearchPalette.border),
              const SizedBox(height: SearchSizes.rowGap),
            ],
            const Text(SearchStrings.noMoreSearch, style: SearchStyle.noMore),
          ],
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          leading,
          const SizedBox(width: SearchSizes.tileToText),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SearchStyle.rowTitle,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: SearchSizes.titleToSubtitle),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SearchStyle.rowSubtitle,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SearchSizes.tileSize,
      height: SearchSizes.tileSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(SearchSizes.tileRadius),
      ),
      child: Icon(
        icon,
        size: SearchSizes.tileIconSize,
        color: SearchPalette.white,
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const fallback = ColoredBox(
      color: SearchPalette.imagePlaceholder,
      child: Icon(Icons.landscape_outlined, color: SearchPalette.white),
    );
    final image = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(SearchSizes.tileRadius),
      child: SizedBox.square(
        dimension: SearchSizes.tileSize,
        child: image == null
            ? fallback
            : Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.recent.toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(SearchStrings.recentSearch, style: SearchStyle.sectionTitle),
          const SizedBox(height: SearchSizes.recentTitleToRow),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const SizedBox(width: SearchSizes.recentGap),
                  _RecentItem(
                    item: items[index],
                    onTap: () => controller.openRecent(items[index]),
                    onLongPress: () => _confirmRemove(context, items[index]),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
  Future<void> _confirmRemove(BuildContext context, RecentSearch item) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.label),
        content: const Text(SearchStrings.removeRecent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove == true) await controller.removeRecent(item);
  }
}

class _RecentItem extends StatelessWidget {
  const _RecentItem({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final RecentSearch item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    const locationCircle = DecoratedBox(
      decoration: BoxDecoration(
        color: SearchPalette.green,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.near_me_outlined,
        size: SearchSizes.recentIconSize,
        color: SearchPalette.white,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: SearchSizes.recentSize + 6,
        child: Column(
          children: [
            SizedBox.square(
              dimension: SearchSizes.recentSize,
              child: url == null
                  ? locationCircle
                  : ClipOval(
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => locationCircle,
                      ),
                    ),
            ),
            const SizedBox(height: SearchSizes.recentImageToLabel),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: SearchStyle.recentLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchActions extends StatelessWidget {
  const _SearchActions({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SearchSizes.recentToActions),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final date = controller.date.value;
            return _ActionCard(
              icon: Icons.calendar_today_outlined,
              label: date == null
                  ? SearchStrings.addDates
                  : MaterialLocalizations.of(context).formatMediumDate(date),
              onTap: controller.addDates,
            );
          }),
          const SizedBox(height: SearchSizes.actionGap),
          Obx(() {
            final pax = controller.pax.value;
            return _ActionCard(
              icon: Icons.groups,
              label: pax == null
                  ? SearchStrings.addPeople
                  : SearchStrings.people(pax),
              onTap: controller.addPeople,
            );
          }),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SearchPalette.white,
        borderRadius: BorderRadius.circular(SearchSizes.actionRadius),
        boxShadow: SearchShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SearchSizes.actionRadius),
          child: SizedBox(
            height: SearchSizes.actionHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SearchSizes.pagePadding,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: SearchSizes.actionIconSize,
                    color: SearchPalette.black,
                  ),
                  const SizedBox(width: SearchSizes.fieldIconGap),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SearchStyle.action,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final error = controller.errorMessage.value;
      final items = controller.results.toList();
      if (error.isNotEmpty || items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            error.isNotEmpty ? error : SearchStrings.noResults,
            textAlign: TextAlign.center,
            style: SearchStyle.noMore,
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(controller.resultsTitle.value, style: SearchStyle.sectionTitle),
          const SizedBox(height: SearchSizes.recentTitleToRow),
          ListingGrid(
            listings: items,
            onListingTap: controller.openListing,
            onWishlistTap: controller.toggleWishlist,
          ),
        ],
      );
    });
  }
}
