import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/booking_detail.dart';
import '../constants/booking_detail_constants.dart';
import '../controllers/booking_detail_controller.dart';
import 'detail_card.dart';

/// "About" — the listing description, clipped with a white fade until the
/// traveller taps "View more".
class AboutSection extends StatelessWidget {
  const AboutSection({required this.about, required this.controller, super.key});

  final String about;
  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          BookingDetailStrings.about,
          textAlign: TextAlign.center,
          style: BookingDetailStyle.cardTitle,
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
                  style: BookingDetailStyle.aboutBody,
                )
              else
                // Capped by line count rather than a fixed height: the box
                // then sizes itself to the text, so a larger system font
                // cannot make the paragraph paint outside its bounds. The
                // fade sits over the last line so it dissolves rather than
                // being cut off.
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Text(
                      about,
                      textAlign: TextAlign.center,
                      maxLines: BookingDetailSizes.aboutCollapsedLines,
                      overflow: TextOverflow.clip,
                      style: BookingDetailStyle.aboutBody,
                    ),
                    const IgnorePointer(
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: BookingDetailGradients.aboutFade,
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
                    constraints: const BoxConstraints(minHeight: 42),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: BookingDetailPalette.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      expanded
                          ? BookingDetailStrings.viewLess
                          : BookingDetailStrings.viewMore,
                      style: BookingDetailStyle.viewMore,
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

/// "Go to page" — the listing this booking was made against.
class RelatedListingCard extends StatelessWidget {
  const RelatedListingCard({
    required this.listing,
    required this.onTap,
    super.key,
  });

  final RelatedListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailThumbnail(
                imageUrl: listing.imageUrl,
                size: BookingDetailSizes.thumbSmall,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.name,
                      style: BookingDetailStyle.listingName,
                    ),
                    if (listing.address.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        listing.address,
                        style: BookingDetailStyle.address,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          DetailLinkRow(
            icon: Icons.open_in_new,
            label: BookingDetailStrings.goToPage,
            onTap: onTap,
            trailing: const Icon(
              Icons.chevron_right,
              size: 20,
              color: BookingDetailPalette.blue,
            ),
          ),
        ],
      ),
    );
  }
}
