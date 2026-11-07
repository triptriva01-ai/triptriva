import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/listing_detail.dart';
import '../../../widgets/booking/booking_bottom_bar.dart';
import '../constants/listing_detail_constants.dart';
import '../controllers/listing_detail_controller.dart';
import '../widgets/listing_hero.dart';
import '../widgets/listing_sections.dart';
import '../widgets/listing_summary.dart';
import '../widgets/nearby_section.dart';
import '../widgets/reviews_section.dart';

/// Listing detail — the product page.
class ListingDetailView extends GetView<ListingDetailController> {
  const ListingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: ListingDetailPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ListingDetailPalette.white,
        // The hero sits behind the status bar, so the body is not inset.
        extendBodyBehindAppBar: true,
        body: Obx(() {
          final detail = controller.detail.value;

          if (detail == null) {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  ListingDetailSizes.pagePadding,
                ),
                child: Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: ListingDetailStyle.aboutBody,
                ),
              ),
            );
          }

          return _Body(detail: detail, controller: controller);
        }),
        bottomNavigationBar: Obx(() {
          final detail = controller.detail.value;
          return BookingBottomBar(
            label: ListingDetailStrings.checkSlots,
            leadingIcon: Icons.calendar_month,
            note: detail?.cancellationNote,
            onPressed: detail == null
                ? null
                : controller.checkSlotAvailability,
          );
        }),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.detail, required this.controller});

  final ListingDetail detail;
  final ListingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: ListingHero(controller: controller)),
        SliverToBoxAdapter(
          child: Transform.translate(
            // The white sheet rides up over the foot of the hero photo.
            offset: const Offset(0, -ListingDetailSizes.sheetOverlap),
            child: Container(
              decoration: const BoxDecoration(
                color: ListingDetailPalette.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ListingDetailSizes.sheetRadius),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                ListingDetailSizes.pagePadding,
                ListingDetailSizes.sectionGap,
                ListingDetailSizes.pagePadding,
                ListingDetailSizes.listBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _sections(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _sections() {
    final host = detail.host;

    return [
      ListingSummary(detail: detail),
      const SizedBox(height: ListingDetailSizes.sectionGap),
      const SectionRule(),
      if (host != null) ...[
        const SizedBox(height: ListingDetailSizes.sectionGap),
        HostRow(host: host),
        const SizedBox(height: ListingDetailSizes.sectionGap),
        const SectionRule(),
      ],
      if (detail.facilities.isNotEmpty) ...[
        const SizedBox(height: ListingDetailSizes.sectionGap),
        BulletSection(
          title: ListingDetailStrings.facilities,
          items: detail.facilities,
        ),
      ],
      if (detail.policies.isNotEmpty) ...[
        const SizedBox(height: ListingDetailSizes.sectionGap),
        BulletSection(
          title: ListingDetailStrings.policies,
          items: detail.policies,
        ),
      ],
      const SizedBox(height: ListingDetailSizes.sectionGap),
      LocationSection(
        mapUrl: detail.mapUrl,
        coordinates: detail.coordinates,
        point: detail.point,
        onTap: controller.openMap,
      ),
      const SizedBox(height: ListingDetailSizes.sectionGap),
      const SectionRule(),
      if (detail.about.isNotEmpty) ...[
        const SizedBox(height: ListingDetailSizes.sectionGap),
        AboutSection(about: detail.about, controller: controller),
        const SizedBox(height: ListingDetailSizes.sectionGap),
        const SectionRule(),
      ],
      const SizedBox(height: ListingDetailSizes.sectionGap),
      ReviewsSection(detail: detail, controller: controller),
      if (detail.nearby.isNotEmpty) ...[
        const SizedBox(height: ListingDetailSizes.sectionGap),
        const SectionRule(),
        const SizedBox(height: ListingDetailSizes.sectionGap),
        NearbySection(
          title: detail.nearbyTitle,
          listings: detail.nearby,
          onListingTap: controller.openNearby,
          onWishlistTap: (_) => controller.toggleWishlist(),
        ),
      ],
    ];
  }
}
