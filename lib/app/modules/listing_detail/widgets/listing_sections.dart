import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/detail/detail_card.dart';
import '../constants/listing_detail_constants.dart';
import '../controllers/listing_detail_controller.dart';
import '../../../data/models/geo_place.dart';
import '../../../widgets/maps/app_maps.dart';

/// "Our Facilities" / "Our Policies" — a wash card of bulleted lines.
class BulletSection extends StatelessWidget {
  const BulletSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              const SizedBox(height: ListingDetailSizes.bulletGap),
            BulletRow(label: items[index]),
          ],
        ],
      ),
    );
  }
}

/// "Our Location" — the map preview and the coordinates under it.
class LocationSection extends StatelessWidget {
  const LocationSection({
    required this.mapUrl,
    required this.coordinates,
    required this.onTap,
    this.point,
    super.key,
  });

  final String mapUrl;
  final String coordinates;

  /// Shown as a live map when known; otherwise [mapUrl] or a neutral tile.
  final GeoPoint? point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          ListingDetailStrings.location,
          textAlign: TextAlign.center,
          style: ListingDetailStyle.sectionTitle,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              ListingDetailSizes.mapRadius,
            ),
            child: Container(
              // A bounded box holding a map image, never text.
              height: ListingDetailSizes.mapHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: ListingDetailPalette.mapBorder),
                borderRadius: BorderRadius.circular(
                  ListingDetailSizes.mapRadius,
                ),
              ),
              child: point != null
                  ? LocationPreviewMap(
                      point: point!,
                      onTap: onTap,
                      height: ListingDetailSizes.mapHeight,
                      radius: ListingDetailSizes.mapRadius,
                    )
                  : mapUrl.isEmpty
                  ? const _MapPlaceholder()
                  : Image.network(
                      mapUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _MapPlaceholder(),
                    ),
            ),
          ),
        ),
        if (coordinates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            coordinates,
            textAlign: TextAlign.center,
            style: ListingDetailStyle.coordinates,
          ),
        ],
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    // No map point for this listing, so the preview is a neutral tile.
    return const ColoredBox(
      color: Color(0xFFEDEDED),
      child: Center(
        child: Icon(
          Icons.map_outlined,
          size: 40,
          color: ListingDetailPalette.muted,
        ),
      ),
    );
  }
}

/// "About" — the description, clipped with a white fade until the traveller
/// taps "View more".
class AboutSection extends StatelessWidget {
  const AboutSection({
    required this.about,
    required this.controller,
    super.key,
  });

  final String about;
  final ListingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          ListingDetailStrings.about,
          textAlign: TextAlign.center,
          style: ListingDetailStyle.sectionTitle,
        ),
        const SizedBox(height: 20),
        Obx(() {
          final expanded = controller.isAboutExpanded.value;

          return Column(
            children: [
              if (expanded)
                Text(
                  about,
                  textAlign: TextAlign.center,
                  style: ListingDetailStyle.aboutBody,
                )
              else
                // Capped by line count rather than a fixed height: the box
                // then sizes itself to the text, so a larger system font
                // cannot make the paragraph paint outside its bounds.
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Text(
                      about,
                      textAlign: TextAlign.center,
                      maxLines: ListingDetailSizes.aboutCollapsedLines,
                      overflow: TextOverflow.clip,
                      style: ListingDetailStyle.aboutBody,
                    ),
                    const IgnorePointer(
                      child: SizedBox(
                        height: ListingDetailSizes.aboutFadeHeight,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: ListingDetailGradients.aboutFade,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.toggleAbout,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: ListingDetailSizes.viewMoreHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ListingDetailPalette.white,
                      borderRadius: BorderRadius.circular(
                        ListingDetailSizes.viewMoreRadius,
                      ),
                    ),
                    child: Text(
                      expanded
                          ? ListingDetailStrings.viewLess
                          : ListingDetailStrings.viewMore,
                      style: ListingDetailStyle.viewMore,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// Flat hairline between the page's top-level sections.
class SectionRule extends StatelessWidget {
  const SectionRule({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 2,
      width: double.infinity,
      child: ColoredBox(color: ListingDetailPalette.rule),
    );
  }
}
