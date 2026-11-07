import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/app_bottom_nav.dart';
import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_selector.dart';
import '../widgets/filter_row.dart';
import '../widgets/fresh_up_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/listing_section.dart';

/// Page 1 — Home / Explore.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: HomePalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: HomePalette.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: HomeSizes.logoToSearch),
              HomeAppBar(controller: controller),
              const SizedBox(height: HomeSizes.logoToSearch),
              HomeSearchBar(controller: controller),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.loadHome,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _HomeContent(controller: controller),
                  ),
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

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: HomeSizes.searchToCategories),
        CategorySelector(controller: controller),
        BannerCarousel(controller: controller),
        const SizedBox(height: HomeSizes.dotsToFilters),
        FilterRow(controller: controller),
        const SizedBox(height: HomeSizes.filtersToSections),
        // `toList()` iterates the RxList inside the builder, which is what
        // registers the observable with Obx. Passing the RxList itself would
        // only be read later, in the child's build, and Obx would throw.
        Obx(
          () => ListingSection(
            title: HomeStrings.mostPopular,
            listings: controller.popular.toList(),
            controller: controller,
          ),
        ),
        const SizedBox(height: HomeSizes.sectionGap),
        Obx(
          () => ListingSection(
            title: HomeStrings.nearBy,
            listings: controller.nearby.toList(),
            controller: controller,
          ),
        ),
        const SizedBox(height: HomeSizes.sectionGap),
        Obx(
          () => FreshUpSection(
            listings: controller.fresh.toList(),
            controller: controller,
          ),
        ),
        const SizedBox(height: HomeSizes.sectionGap),
        Obx(
          () => ListingSection(
            title: HomeStrings.newAdventure,
            listings: controller.newAdventures.toList(),
            controller: controller,
          ),
        ),
        const SizedBox(height: HomeSizes.sectionGap),
      ],
    );
  }
}
